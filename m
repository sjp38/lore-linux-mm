Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E55456B004A
	for <linux-mm@kvack.org>; Thu, 14 Jul 2011 16:15:45 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit
Date: Thu, 14 Jul 2011 16:15:35 -0400
From: mail@rsmogura.net
Subject: Re: Hugepages for shm page cache (defrag)
In-Reply-To: <alpine.LSU.2.00.1107071643370.10165@sister.anvils>
References: <201107062131.01717.mail@smogura.eu>
 <m2pqlmy7z8.fsf@firstfloor.org>
 <5be3df4081574f3d4e1e699f028549a7@rsmogura.net>
 <alpine.LSU.2.00.1107071643370.10165@sister.anvils>
Message-ID: <60ac3a8f762dcc7a6e8767753ad55736@rsmogura.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Radislaw Smogura <mail@rsmogura.eu>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, aarcange@redhat.com

On Thu, 7 Jul 2011 17:07:47 -0700 (PDT), Hugh Dickins wrote:
> On Thu, 7 Jul 2011, mail@rsmogura.net wrote:
>> On Wed, 06 Jul 2011 22:28:59 -0700, Andi Kleen wrote:
>> > RadosA?aw Smogura <mail@smogura.eu> writes:
>> >
>> > > Hello,
>> > >
>> > > This is may first try with Linux patch, so please do not blame 
>> me too
>> > > much.
>> > > Actually I started with small idea to add MAP_HUGTLB for 
>> /dev/shm but it
>> > > grew
>> > > up in something more like support for huge pages in page cache, 
>> but
>> > > according
>> > > to documentation to submit alpha-work too, I decided to send 
>> this.
>> >
>> > Shouldn't this be rather integrated with the normal transparent 
>> huge
>> > pages? It seems odd to develop parallel infrastructure.
>> >
>> > -Andi
>
> Although Andi's sig says "Speaking for myself only",
> he is very much speaking for me on this too ;)
>
> There is definitely interest in extending Transparent Huge Pages to 
> tmpfs;
> though so far as I know, nobody has yet had time to think through 
> just
> what that will entail.
>
> Correspondingly, I'm afraid there would be little interest in adding 
> yet
> another variant of hugepages into the kernel - enough ugliness 
> already!
>
>> It's not quite good to ask me about this, as I'm starting hacker, 
>> but I
>> think it should be treated as counterpart for page cache, and 
>> actually I got
>> few "collisions" with THP.
>>
>> High level design will probably be the same (e.g. I use defrag_, THP 
>> uses
>> collapse_ for creating huge page), but in contrast I try to operate 
>> on page
>> cache, so in some way file system must be huge page aware (shm fs is 
>> not, as
>> it can move page from page cache to swap cache - it may silently 
>> fragment
>> de-fragmented areas).
>>
>> I put some requirements for work, e. g. mapping file as huge should 
>> not
>> affect previous or future, even fancy, non huge mappings, both 
>> callers
>> should succeed and get this what they asked for.
>>
>> Of course I think how to make it more "transparent" without need of 
>> file
>> system support, but I suppose it may be dead-corner.
>>
>> I still want to emphasise it's really alpha version.
>
> I barely looked at it, but did notice that scripts/checkpatch.pl 
> reports
> 127 errors and 111 warnings, plus it seems to be significantly 
> incomplete
> (an extern declaration of defragPageCache() but not the function 
> itself).
>
> And it serves no purpose without the pte work you mention (there
> is no point to a shmem hugepage unless it is mapped in that way).
>
> Sorry to be discouraging, but extending THP is likely to be the way 
> to go.
>
> Hugh
Hi,
I working to remove errors from patch, and I integrated it with current 
THP infrastructure a little bit, but I want ask if following I do 
following - it's about get_page, put_page, get_page_unless_zero, 
put_page_test_zero.

I want following logic I think it may be better (in x86):
1) Each THP page will start with 512 refcount (self + 511 tails)
2) Each get/put will increment usage count only on this page, same test 
variants will do (currently those do not make this, so split is broken)
3) On compounds put page will call put_page_test_zero, if true, it will 
do compound lock, ask again if it has 0, if yes it will decrease 
refcount of head, if it will fall to zero compound will be freed (double 
check lock).
4) Compound lock is this what caller will need to establish if it needs 
to operate on transparent huge page in whole.

Motivation:
I operate on page cache, many assumptions about concurrent call of 
put/get_page are and plain using those causes memory leaks, faults, 
dangling pointers, etc when I'm going to split compound page.

Is this acceptable?

Regards,
Radek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

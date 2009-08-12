Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9902C6B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 15:04:58 -0400 (EDT)
Received: by qyk36 with SMTP id 36so219572qyk.12
        for <linux-mm@kvack.org>; Wed, 12 Aug 2009 12:04:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0908121841550.14314@sister.anvils>
References: <a1b36c3a0908101347t796dedbat2ecb0535c32f325b@mail.gmail.com>
	 <Pine.LNX.4.64.0908121841550.14314@sister.anvils>
Date: Wed, 12 Aug 2009 15:04:51 -0400
Message-ID: <a1b36c3a0908121204q1b59df1fk86afec9d05ec16dc@mail.gmail.com>
Subject: Re: vma_merge issue
From: Bill Speirs <bill.speirs@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 12, 2009 at 2:26 PM, Hugh Dickins<hugh.dickins@tiscali.co.uk> w=
rote:
> On Mon, 10 Aug 2009, Bill Speirs wrote:
>>
>> I came across an issue where adjacent pages are not properly coalesced
>> together when changing protections on them. This can be shown by doing
>> the following:
>>
>> 1) Map 3 pages with PROT_NONE and MAP_PRIVATE | MAP_ANONYMOUS
>> 2) Set the middle page's protection to PROT_READ | PROT_WRITE
>> 3) Set the middle page's protection back to PROT_NONE
>>
>> You are left with 3 entries in /proc/self/map where you should only
>> have 1. If you only change the protection to PROT_READ in step 2, then
>> it is properly merged together. I noticed in mprotect.c the following
>> comment in the function mprotect_fixup; I'm not sure if it applies or
>> not:
>> =A0 =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0 =A0* If we make a private mapping writable we increase o=
ur commit;
>> =A0 =A0 =A0 =A0 =A0* but (without finer accounting) cannot reduce our co=
mmit if we
>> =A0 =A0 =A0 =A0 =A0* make it unwritable again.
> [ the following lines of the comment are not relevant here so I'll delete=
 ]
>> =A0 =A0 =A0 =A0 =A0*/
>>
>> I think this only applies to setting charged =3D nrpages; however,
>> VM_ACCOUNT is also added to newflags. Could it be that the adjacent
>> blocks don't have VM_ACCOUNT and so the call to vma_merge cannot merge
>> because the flags for the adjacent vma are not the same?
>
> That's right, and it is working as intended.
>
> To allow people to set up enormous PROT_READ,MAP_PRIVATE mappings
> "for free", we don't account those initially, but only as parts
> are mprotected writable later: at that point they're accounted,
> and marked VM_ACCOUNT so that we know it's been done (and don't
> double account later on).
>
> So your middle page has been accounted (one page added to
> /proc/meminfo's Committed_AS, which isn't allowed to exceed CommitLimit
> if /proc/sys/vm/overcommit_memory is 2 to disable overcommit), but the
> neighbouring pages have not been accounted: so we need separate vmas
> for them, I'm afraid, since that accounting is done per vma.
>
>>
>> Can anyone shed some light on this? While it isn't an issue for 3
>> pages, I'm mmaping 200K+ pages and changing the perms on random pages
>> throughout and then back but I quickly run into the max_map_count when
>> I don't actually need that many mappings.
>
> But that's easily dealt with: just make your mmap PROT_READ|PROT_WRITE,
> which will account for the whole extent; then mprotect it all PROT_NONE,
> which will take you to your previous starting position; then proceed as
> before - the vmas should get merged as they are reset back to PROT_NONE.
> That works, doesn't it?

Unfortunately, that doesn't work. When I mmap pages as PROT_WRITE it
is checked against the CommitLimit and returns with ENOMEM as I'm
mmaping a lot of pages. However, I don't actually want to be charged
for that memory, as I won't be using all of it. This is why I mmap as
PROT_NONE as I'm not charged for it. Then when I set a page to
PROT_WRITE I get charged (which is expected and OK), but then going
back to PROT_NONE I don't get "uncharged". This makes sense as I could
simply PROT_WRITE that page again and I should be charged. However, I
have no way (that I know of) to tell the kernel "I'm done with this
page, don't charge me for it, and set it's protection to PROT_NONE."
I've tried madvise with MADV_DONTNEED but that doesn't seem to remove
the VM_ACCOUNT flag.

I have seen an mm patch that introduces MADV_FREE, which I believe
removes the VM_ACCOUNT flag and decrements the commit charge. Does it
make sense to have this type of functionality? Can I get this same
type of functionality (start without being charged for a page, use it,
then un-use it and remove the charge for it?) currently?

> (I must offer a big thank you: replying to your mail just after writing
> a mail about the ZERO_PAGE, brings me to realize - if I'm not mistaken -
> that we broke the accounting of initially non-writable anonymous areas
> when we stopped using the ZERO_PAGE there, but marked readfaulted pages
> as dirty. =A0Looks like another argument to bring them back.)

I'm not 100% sure what you're talking about with respect to ZERO_PAGE,
but I'm happy to help :-)

Bill-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

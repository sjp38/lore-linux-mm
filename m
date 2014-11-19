Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 964EE6B0038
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 09:36:47 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id l18so1016716wgh.30
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 06:36:47 -0800 (PST)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com. [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id x5si1287182wiy.6.2014.11.19.06.36.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 19 Nov 2014 06:36:46 -0800 (PST)
Received: by mail-wg0-f42.google.com with SMTP id z12so1043209wgg.1
        for <linux-mm@kvack.org>; Wed, 19 Nov 2014 06:36:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <546BDB29.9050403@suse.cz>
References: <502D42E5.7090403@redhat.com>
	<20120818000312.GA4262@evergreen.ssec.wisc.edu>
	<502F100A.1080401@redhat.com>
	<alpine.LSU.2.00.1208200032450.24855@eggly.anvils>
	<CANN689Ej7XLh8VKuaPrTttDrtDGQbXuYJgS2uKnZL2EYVTM3Dg@mail.gmail.com>
	<20120822032057.GA30871@google.com>
	<50345232.4090002@redhat.com>
	<20130603195003.GA31275@evergreen.ssec.wisc.edu>
	<20141114163053.GA6547@cosmos.ssec.wisc.edu>
	<20141117160212.b86d031e1870601240b0131d@linux-foundation.org>
	<20141118014135.GA17252@cosmos.ssec.wisc.edu>
	<546AB1F5.6030306@redhat.com>
	<20141118121936.07b02545a0684b2cc839a10c@linux-foundation.org>
	<CALYGNiMxnxmy-LyJ4OT9OoFeKwTPPkZMF-bJ-eJDBFXgZQ6AEA@mail.gmail.com>
	<CALYGNiM_CsjjiK_36JGirZT8rTP+ROYcH0CSyZjghtSNDU8ptw@mail.gmail.com>
	<546BDB29.9050403@suse.cz>
Date: Wed, 19 Nov 2014 18:36:45 +0400
Message-ID: <CALYGNiOHXvyqr3+Jq5FsZ_xscsXwrQ_9YCtL2819i6iRkgms2w@mail.gmail.com>
Subject: Re: [PATCH] Repeated fork() causes SLAB to grow without bound
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tim Hartrick <tim@edgecast.com>, Michal Hocko <mhocko@suse.cz>

On Wed, Nov 19, 2014 at 2:50 AM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 11/19/2014 12:02 AM, Konstantin Khlebnikov wrote:
>> On Wed, Nov 19, 2014 at 1:15 AM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>>> On Tue, Nov 18, 2014 at 11:19 PM, Andrew Morton
>>> <akpm@linux-foundation.org> wrote:
>>>> On Mon, 17 Nov 2014 21:41:57 -0500 Rik van Riel <riel@redhat.com> wrote:
>>>>
>>>>> > Because of the serial forking there does indeed end up being an
>>>>> > infinite number of vmas.  The initial vma can never be deleted
>>>>> > (even though the initial parent process has long since terminated)
>>>>> > because the initial vma is referenced by the children.
>>>>>
>>>>> There is a finite number of VMAs, but an infite number of
>>>>> anon_vmas.
>>>>>
>>>>> Subtle, yet deadly...
>>>>
>>>> Well, we clearly have the data structures screwed up.  I've forgotten
>>>> enough about this code for me to be unable to work out what the fixed
>>>> up data structures would look like :( But surely there is some proper
>>>> solution here.  Help?
>>>
>>> Not sure if it's right but probably we could reuse on fork an old anon_vma
>>> from the chain if it's already lost all vmas which points to it.
>>> For endlessly forking exploit this should work mostly like proposed patch
>>> which stops branching after some depth but without magic constant.
>>
>> Something like this. I leave proper comment for tomorrow.
>
> Hmm I'm not sure that will work as it is. If I understand it correctly, your
> patch can detect if the parent's anon_vma has no own references at the fork()
> time. But at the fork time, the parent is still alive, it only exits after the
> fork, right? So I guess it still has own references and the child will still
> allocate its new anon_vma, and the problem is not solved.

But it could reuse anon_vma from grandparent or older.
Count of anon_vmas in chain will be limited with count of alive processes.

I think it's better to describe this in terms of sets of anon_vma
instead hierarchy:
at clone vma inherits pages from parent together with set of anon_vma
which they belong.
For new pages it might allocate new anon_vma or reuse existing. After
my patch vma
will try to reuse anon_vma from that set which has no vmas which points to it.
As a result there will be no parent-child relation between anon_vma and
multiple pages might have equal (anon_vma, index) pair but I see no
problems here.

>
> So maybe we could detect that the own references dropped to zero when the parent
> does exit, and then change mapping of all relevant pages to the root anon_vma,
> destroy avc's of children and the anon_vma itself. But that sounds quite
> heavyweight :/
>
> Vlastimil
>
>>>
>>>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

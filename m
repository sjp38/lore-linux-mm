Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id C2F6F6B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 18:50:04 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id n3so3624949wiv.5
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 15:50:04 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t5si440739wjr.21.2014.11.18.15.50.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Nov 2014 15:50:03 -0800 (PST)
Message-ID: <546BDB29.9050403@suse.cz>
Date: Wed, 19 Nov 2014 00:50:01 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] Repeated fork() causes SLAB to grow without bound
References: <502D42E5.7090403@redhat.com>	<20120818000312.GA4262@evergreen.ssec.wisc.edu>	<502F100A.1080401@redhat.com>	<alpine.LSU.2.00.1208200032450.24855@eggly.anvils>	<CANN689Ej7XLh8VKuaPrTttDrtDGQbXuYJgS2uKnZL2EYVTM3Dg@mail.gmail.com>	<20120822032057.GA30871@google.com>	<50345232.4090002@redhat.com>	<20130603195003.GA31275@evergreen.ssec.wisc.edu>	<20141114163053.GA6547@cosmos.ssec.wisc.edu>	<20141117160212.b86d031e1870601240b0131d@linux-foundation.org>	<20141118014135.GA17252@cosmos.ssec.wisc.edu>	<546AB1F5.6030306@redhat.com>	<20141118121936.07b02545a0684b2cc839a10c@linux-foundation.org>	<CALYGNiMxnxmy-LyJ4OT9OoFeKwTPPkZMF-bJ-eJDBFXgZQ6AEA@mail.gmail.com> <CALYGNiM_CsjjiK_36JGirZT8rTP+ROYcH0CSyZjghtSNDU8ptw@mail.gmail.com>
In-Reply-To: <CALYGNiM_CsjjiK_36JGirZT8rTP+ROYcH0CSyZjghtSNDU8ptw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tim Hartrick <tim@edgecast.com>, Michal Hocko <mhocko@suse.cz>

On 11/19/2014 12:02 AM, Konstantin Khlebnikov wrote:
> On Wed, Nov 19, 2014 at 1:15 AM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
>> On Tue, Nov 18, 2014 at 11:19 PM, Andrew Morton
>> <akpm@linux-foundation.org> wrote:
>>> On Mon, 17 Nov 2014 21:41:57 -0500 Rik van Riel <riel@redhat.com> wrote:
>>>
>>>> > Because of the serial forking there does indeed end up being an
>>>> > infinite number of vmas.  The initial vma can never be deleted
>>>> > (even though the initial parent process has long since terminated)
>>>> > because the initial vma is referenced by the children.
>>>>
>>>> There is a finite number of VMAs, but an infite number of
>>>> anon_vmas.
>>>>
>>>> Subtle, yet deadly...
>>>
>>> Well, we clearly have the data structures screwed up.  I've forgotten
>>> enough about this code for me to be unable to work out what the fixed
>>> up data structures would look like :( But surely there is some proper
>>> solution here.  Help?
>>
>> Not sure if it's right but probably we could reuse on fork an old anon_vma
>> from the chain if it's already lost all vmas which points to it.
>> For endlessly forking exploit this should work mostly like proposed patch
>> which stops branching after some depth but without magic constant.
> 
> Something like this. I leave proper comment for tomorrow.

Hmm I'm not sure that will work as it is. If I understand it correctly, your
patch can detect if the parent's anon_vma has no own references at the fork()
time. But at the fork time, the parent is still alive, it only exits after the
fork, right? So I guess it still has own references and the child will still
allocate its new anon_vma, and the problem is not solved.

So maybe we could detect that the own references dropped to zero when the parent
does exit, and then change mapping of all relevant pages to the root anon_vma,
destroy avc's of children and the anon_vma itself. But that sounds quite
heavyweight :/

Vlastimil

>>
>>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

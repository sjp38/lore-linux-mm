Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 577976B0032
	for <linux-mm@kvack.org>; Wed, 28 Aug 2013 23:04:42 -0400 (EDT)
Received: by mail-wg0-f51.google.com with SMTP id b12so3957462wgh.30
        for <linux-mm@kvack.org>; Wed, 28 Aug 2013 20:04:40 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <521DE5D7.4040305@synopsys.com>
References: <CA+icZUXuw7QBn4CPLLuiVUjHin0m6GRdbczGw=bZY+Z60sXNow@mail.gmail.com>
	<CA+icZUVbUD1tUa_ORtn_ZZebpp3gXXHGAcNe0NdYPXPMPoABuA@mail.gmail.com>
	<1372192414.1888.8.camel@buesod1.americas.hpqcorp.net>
	<CA+icZUXgOd=URJBH5MGAZKdvdkMpFt+5mRxtzuDzq_vFHpoc2A@mail.gmail.com>
	<1372202983.1888.22.camel@buesod1.americas.hpqcorp.net>
	<521DE5D7.4040305@synopsys.com>
Date: Thu, 29 Aug 2013 05:04:40 +0200
Message-ID: <CA+icZUUrZG8pYqKcHY3DcYAuuw=vbdUvs6ZXDq5meBMjj6suFg@mail.gmail.com>
Subject: Re: ipc-msg broken again on 3.11-rc7? (was Re: linux-next: Tree for
 Jun 21 [ BROKEN ipc/ipc-msg ])
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-next <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Manfred Spraul <manfred@colorfullife.com>, Jonathan Gonzalez <jgonzalez@linets.cl>

On Wed, Aug 28, 2013 at 1:58 PM, Vineet Gupta
<Vineet.Gupta1@synopsys.com> wrote:
> Hi David,
>
> On 06/26/2013 04:59 AM, Davidlohr Bueso wrote:
>> On Tue, 2013-06-25 at 23:41 +0200, Sedat Dilek wrote:
>>> On Tue, Jun 25, 2013 at 10:33 PM, Davidlohr Bueso
>>> <davidlohr.bueso@hp.com> wrote:
>>>> On Tue, 2013-06-25 at 18:10 +0200, Sedat Dilek wrote:
>>>> [...]
>>>>
>>>>> I did some more testing with Linux-Testing-Project (release:
>>>>> ltp-full-20130503) and next-20130624 (Monday) which has still the
>>>>> issue, here.
>>>>>
>>>>> If I revert the mentioned two commits from my local
>>>>> revert-ipc-next20130624-5089fd1c6a6a-ab9efc2d0db5 GIT repo, everything
>>>>> is fine.
>>>>>
>>>>> I have tested the LTP ***IPC*** and ***SYSCALLS*** testcases.
>>>>>
>>>>>    root# ./runltp -f ipc
>>>>>
>>>>>    root# ./runltp -f syscalls
>>>>
>>>> These are nice test cases!
>>>>
>>>> So I was able to reproduce the issue with LTP and manually running
>>>> msgctl08. We seemed to be racing at find_msg(), so take to q_perm lock
>>>> before calling it. The following changes fixes the issue and passes all
>>>> 'runltp -f syscall' tests, could you give it a try?
>>>>
>>>
>>> Cool, that fixes the issues here.
>>>
>>> Building with fakeroot & make deb-pkg is now OK, again.
>>>
>>> The syscalls/msgctl08 test-case ran successfully!
>>
>> Andrew, could you pick this one up? I've made the patch on top of
>> 3.10.0-rc7-next-20130625
>
> LTP msgctl08 hangs on 3.11-rc7 (ARC port) with some of my local changes. I
> bisected it, sigh... didn't look at this thread earlier :-( and landed into this.
>
> ------------->8------------------------------------
> 3dd1f784ed6603d7ab1043e51e6371235edf2313 is the first bad commit
> commit 3dd1f784ed6603d7ab1043e51e6371235edf2313
> Author: Davidlohr Bueso <davidlohr.bueso@hp.com>
> Date:   Mon Jul 8 16:01:17 2013 -0700
>
>     ipc,msg: shorten critical region in msgsnd
>
>     do_msgsnd() is another function that does too many things with the ipc
>     object lock acquired.  Take it only when needed when actually updating
>     msq.
> ------------->8------------------------------------
>
> If I revert 3dd1f784ed66 and 9ad66ae "ipc: remove unused functions" - the test
> passes. I can confirm that linux-next also has the issue (didn't try the revert
> there though).
>
> 1. arc 3.11-rc7 config attached (UP + PREEMPT)
> 2. dmesg prints "msgmni has been set to 479"
> 3. LTP output (this is slightly dated source, so prints might vary)
>
> ------------->8------------------------------------
> <<<test_start>>>
> tag=msgctl08 stime=1377689180
> cmdline="msgctl08"
> contacts=""
> analysis=exit
> initiation_status="ok"
> <<<test_output>>>
> ------------->8-------- hung here ------------------
>
>
> Let me know if you need more data/test help.
>

Cannot say much to your constellation as I had the issue on x86-64 and
Linux-next.
But I have just seen a post-v3.11-rc7 IPC-fix in [1].

I have here a v3.11-rc7 kernel with drm-intel-nightly on top... did not run LTP.

Which LTP release do you use?
Might be good to attach your kernel-config for followers?

- Sedat -

[1] http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=368ae537e056acd3f751fa276f48423f06803922

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

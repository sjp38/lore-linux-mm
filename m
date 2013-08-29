Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id EAA016B0032
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 03:21:56 -0400 (EDT)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: ipc-msg broken again on 3.11-rc7? (was Re: linux-next: Tree for
 Jun 21 [ BROKEN ipc/ipc-msg ])
Date: Thu, 29 Aug 2013 07:21:49 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA23075140FA3@IN01WEMBXA.internal.synopsys.com>
References: <CA+icZUXuw7QBn4CPLLuiVUjHin0m6GRdbczGw=bZY+Z60sXNow@mail.gmail.com>
	<CA+icZUVbUD1tUa_ORtn_ZZebpp3gXXHGAcNe0NdYPXPMPoABuA@mail.gmail.com>
	<1372192414.1888.8.camel@buesod1.americas.hpqcorp.net>
	<CA+icZUXgOd=URJBH5MGAZKdvdkMpFt+5mRxtzuDzq_vFHpoc2A@mail.gmail.com>
	<1372202983.1888.22.camel@buesod1.americas.hpqcorp.net>
	<521DE5D7.4040305@synopsys.com>
 <CA+icZUUrZG8pYqKcHY3DcYAuuw=vbdUvs6ZXDq5meBMjj6suFg@mail.gmail.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "sedat.dilek@gmail.com" <sedat.dilek@gmail.com>
Cc: Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-next <linux-next@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Stephen
 Rothwell <sfr@canb.auug.org.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Manfred Spraul <manfred@colorfullife.com>, Jonathan
 Gonzalez <jgonzalez@linets.cl>

On 08/29/2013 08:34 AM, Sedat Dilek wrote:=0A=
> On Wed, Aug 28, 2013 at 1:58 PM, Vineet Gupta=0A=
> <Vineet.Gupta1@synopsys.com> wrote:=0A=
>> Hi David,=0A=
>>=0A=
>> On 06/26/2013 04:59 AM, Davidlohr Bueso wrote:=0A=
>>> On Tue, 2013-06-25 at 23:41 +0200, Sedat Dilek wrote:=0A=
>>>> On Tue, Jun 25, 2013 at 10:33 PM, Davidlohr Bueso=0A=
>>>> <davidlohr.bueso@hp.com> wrote:=0A=
>>>>> On Tue, 2013-06-25 at 18:10 +0200, Sedat Dilek wrote:=0A=
>>>>> [...]=0A=
>>>>>=0A=
>>>>>> I did some more testing with Linux-Testing-Project (release:=0A=
>>>>>> ltp-full-20130503) and next-20130624 (Monday) which has still the=0A=
>>>>>> issue, here.=0A=
>>>>>>=0A=
>>>>>> If I revert the mentioned two commits from my local=0A=
>>>>>> revert-ipc-next20130624-5089fd1c6a6a-ab9efc2d0db5 GIT repo, everythi=
ng=0A=
>>>>>> is fine.=0A=
>>>>>>=0A=
>>>>>> I have tested the LTP ***IPC*** and ***SYSCALLS*** testcases.=0A=
>>>>>>=0A=
>>>>>>    root# ./runltp -f ipc=0A=
>>>>>>=0A=
>>>>>>    root# ./runltp -f syscalls=0A=
>>>>> These are nice test cases!=0A=
>>>>>=0A=
>>>>> So I was able to reproduce the issue with LTP and manually running=0A=
>>>>> msgctl08. We seemed to be racing at find_msg(), so take to q_perm loc=
k=0A=
>>>>> before calling it. The following changes fixes the issue and passes a=
ll=0A=
>>>>> 'runltp -f syscall' tests, could you give it a try?=0A=
>>>>>=0A=
>>>> Cool, that fixes the issues here.=0A=
>>>>=0A=
>>>> Building with fakeroot & make deb-pkg is now OK, again.=0A=
>>>>=0A=
>>>> The syscalls/msgctl08 test-case ran successfully!=0A=
>>> Andrew, could you pick this one up? I've made the patch on top of=0A=
>>> 3.10.0-rc7-next-20130625=0A=
>> LTP msgctl08 hangs on 3.11-rc7 (ARC port) with some of my local changes.=
 I=0A=
>> bisected it, sigh... didn't look at this thread earlier :-( and landed i=
nto this.=0A=
>>=0A=
>> ------------->8------------------------------------=0A=
>> 3dd1f784ed6603d7ab1043e51e6371235edf2313 is the first bad commit=0A=
>> commit 3dd1f784ed6603d7ab1043e51e6371235edf2313=0A=
>> Author: Davidlohr Bueso <davidlohr.bueso@hp.com>=0A=
>> Date:   Mon Jul 8 16:01:17 2013 -0700=0A=
>>=0A=
>>     ipc,msg: shorten critical region in msgsnd=0A=
>>=0A=
>>     do_msgsnd() is another function that does too many things with the i=
pc=0A=
>>     object lock acquired.  Take it only when needed when actually updati=
ng=0A=
>>     msq.=0A=
>> ------------->8------------------------------------=0A=
>>=0A=
>> If I revert 3dd1f784ed66 and 9ad66ae "ipc: remove unused functions" - th=
e test=0A=
>> passes. I can confirm that linux-next also has the issue (didn't try the=
 revert=0A=
>> there though).=0A=
>>=0A=
>> 1. arc 3.11-rc7 config attached (UP + PREEMPT)=0A=
>> 2. dmesg prints "msgmni has been set to 479"=0A=
>> 3. LTP output (this is slightly dated source, so prints might vary)=0A=
>>=0A=
>> ------------->8------------------------------------=0A=
>> <<<test_start>>>=0A=
>> tag=3Dmsgctl08 stime=3D1377689180=0A=
>> cmdline=3D"msgctl08"=0A=
>> contacts=3D""=0A=
>> analysis=3Dexit=0A=
>> initiation_status=3D"ok"=0A=
>> <<<test_output>>>=0A=
>> ------------->8-------- hung here ------------------=0A=
>>=0A=
>>=0A=
>> Let me know if you need more data/test help.=0A=
>>=0A=
> Cannot say much to your constellation as I had the issue on x86-64 and=0A=
> Linux-next.=0A=
> But I have just seen a post-v3.11-rc7 IPC-fix in [1].=0A=
>=0A=
> I have here a v3.11-rc7 kernel with drm-intel-nightly on top... did not r=
un LTP.=0A=
=0A=
Not sure what you mean - I'd posted that Im seeing the issue on ARC Linux (=
an FPGA=0A=
board) 3.11-rc7 as well as linux-next of yesterday.=0A=
=0A=
> Which LTP release do you use?=0A=
=0A=
The LTP build I generally use is from a 2007 based sources (lazy me). Howev=
er I=0A=
knew this would come up so before posting, I'd built the latest from buildr=
oot and=0A=
ran the msgctl08 from there standalone and it did the same thing.=0A=
=0A=
> Might be good to attach your kernel-config for followers?=0A=
=0A=
It was already there in my orig msg - you probably missed it.=0A=
=0A=
> [1] http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit=
/?id=3D368ae537e056acd3f751fa276f48423f06803922=0A=
=0A=
I tried linux-next of today, same deal - msgctl08 still hangs.=0A=
=0A=
-Vineet=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

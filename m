Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f43.google.com (mail-oa0-f43.google.com [209.85.219.43])
	by kanga.kvack.org (Postfix) with ESMTP id A619E6B0092
	for <linux-mm@kvack.org>; Sat, 12 Apr 2014 11:33:55 -0400 (EDT)
Received: by mail-oa0-f43.google.com with SMTP id eb12so7493994oac.2
        for <linux-mm@kvack.org>; Sat, 12 Apr 2014 08:33:52 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id lr2si10333659obb.44.2014.04.12.08.33.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 12 Apr 2014 08:33:52 -0700 (PDT)
Message-ID: <1397316828.2686.6.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] ipc,shm: disable shmmax and shmall by default
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Sat, 12 Apr 2014 08:33:48 -0700
In-Reply-To: <5348FE43.1070508@colorfullife.com>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
	 <1396371699.25314.11.camel@buesod1.americas.hpqcorp.net>
	 <CAHGf_=qsf6vN5k=-PLraG8Q_uU1pofoBDktjVH1N92o76xPadQ@mail.gmail.com>
	 <1396377083.25314.17.camel@buesod1.americas.hpqcorp.net>
	 <CAHGf_=rLLBDr5ptLMvFD-M+TPQSnK3EP=7R+27K8or84rY-KLA@mail.gmail.com>
	 <1396386062.25314.24.camel@buesod1.americas.hpqcorp.net>
	 <CAHGf_=rhXrBQSmDBJJ-vPxBbhjJ91Fh2iWe1cf_UQd-tCfpb2w@mail.gmail.com>
	 <20140401142947.927642a408d84df27d581e36@linux-foundation.org>
	 <CAHGf_=p70rLOYwP2OgtK+2b+41=GwMA9R=rZYBqRr1w_O5UnKA@mail.gmail.com>
	 <20140401144801.603c288674ab8f417b42a043@linux-foundation.org>
	 <CAHGf_=r5AUu6yvJgOzwYDghBo6iT2q+nNumpvqwer+igcfChrA@mail.gmail.com>
	 <1396394931.25314.34.camel@buesod1.americas.hpqcorp.net>
	 <CAHGf_=rH+vfFzRrh35TETxjFU2HM0xnDQFweQ+Bfw20Pm2nL3g@mail.gmail.com>
	 <1396484447.2953.1.camel@buesod1.americas.hpqcorp.net>
	 <5348343F.6030300@colorfullife.com>
	 <1397248035.2503.20.camel@buesod1.americas.hpqcorp.net>
	 <5348FE43.1070508@colorfullife.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg Thelen <gthelen@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Sat, 2014-04-12 at 10:50 +0200, Manfred Spraul wrote:
> On 04/11/2014 10:27 PM, Davidlohr Bueso wrote:
> > On Fri, 2014-04-11 at 20:28 +0200, Manfred Spraul wrote:
> >> Hi Davidlohr,
> >>
> >> On 04/03/2014 02:20 AM, Davidlohr Bueso wrote:
> >>> The default size for shmmax is, and always has been, 32Mb.
> >>> Today, in the XXI century, it seems that this value is rather small,
> >>> making users have to increase it via sysctl, which can cause
> >>> unnecessary work and userspace application workarounds[1].
> >>>
> >>> [snip]
> >>> Running this patch through LTP, everything passes, except the following,
> >>> which, due to the nature of this change, is quite expected:
> >>>
> >>> shmget02    1  TFAIL  :  call succeeded unexpectedly
> >> Why is this TFAIL expected?
> > So looking at shmget02.c, this is the case that fails:
> >
> > 		for (i = 0; i < TST_TOTAL; i++) {
> > 			/*
> > 			 * Look for a failure ...
> > 			 */
> >
> > 			TEST(shmget(*(TC[i].skey), TC[i].size, TC[i].flags));
> >
> > 			if (TEST_RETURN != -1) {
> > 				tst_resm(TFAIL, "call succeeded unexpectedly");
> > 				continue;
> > 			}
> >
> > Where TC[0] is:
> > struct test_case_t {
> > 	int *skey;
> > 	int size;
> > 	int flags;
> > 	int error;
> > } TC[] = {
> > 	/* EINVAL - size is 0 */
> > 	{
> > 	&shmkey2, 0, IPC_CREAT | IPC_EXCL | SHM_RW, EINVAL},
> >
> > So it's expected because now 0 is actually valid. And before:
> >
> >   EINVAL A new segment was to be created and size < SHMMIN or size > SHMMAX
> >
> >>> diff --git a/ipc/shm.c b/ipc/shm.c
> >>> index 7645961..ae01ffa 100644
> >>> --- a/ipc/shm.c
> >>> +++ b/ipc/shm.c
> >>> @@ -490,10 +490,12 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
> >>>    	int id;
> >>>    	vm_flags_t acctflag = 0;
> >>>    
> >>> -	if (size < SHMMIN || size > ns->shm_ctlmax)
> >>> +	if (ns->shm_ctlmax &&
> >>> +	    (size < SHMMIN || size > ns->shm_ctlmax))
> >>>    		return -EINVAL;
> >>>    
> >>> -	if (ns->shm_tot + numpages > ns->shm_ctlall)
> >>> +	if (ns->shm_ctlall &&
> >>> +	    ns->shm_tot + numpages > ns->shm_ctlall)
> >>>    		return -ENOSPC;
> >>>    
> >>>    	shp = ipc_rcu_alloc(sizeof(*shp));
> >> Ok, I understand it:
> >> Your patch disables checking shmmax, shmall *AND* checking for SHMMIN.
> > Right, if shmmax is 0, then there's no point checking for shmmin,
> > otherwise we'd always end up returning EINVAL.
> >
> >> a) Have you double checked that 0-sized shm segments work properly?
> >>    Does the swap code handle it properly, ...? EINVAL A new segment was to be created and size < SHMMIN or size > SHMMAX
> > Hmm so I've been using this patch just fine on my laptop since I sent
> > it. So far I haven't seen any issues. Are you refering to something in
> > particular? I'd be happy to run any cases you're concerned with.
> I'm thinking about malicious applications.
> Create 0-sized segments and then map them. Does find_vma_intersection 
> handle that case?
> The same for all other functions that are called by the shm code.

Right I agree, which is why I corrected it in v2.

> You can't replace code review by "runs for a month"

Manfred, I was not referring to that at all.

> >> b) It's that yet another risk for user space incompatibility?
> > Sorry, I don't follow here.
> Applications expect that shmget(,0,) fails.

Again, v2.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

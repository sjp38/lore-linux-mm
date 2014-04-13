Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id DA9F16B00C1
	for <linux-mm@kvack.org>; Sun, 13 Apr 2014 19:15:43 -0400 (EDT)
Received: by mail-ob0-f171.google.com with SMTP id uy5so1361230obc.2
        for <linux-mm@kvack.org>; Sun, 13 Apr 2014 16:15:42 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id eh9si12791616oeb.28.2014.04.13.16.15.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 13 Apr 2014 16:15:42 -0700 (PDT)
Message-ID: <1397430940.31076.2.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Sun, 13 Apr 2014 16:15:40 -0700
In-Reply-To: <534AD1EE.3050705@colorfullife.com>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
	 <1396306773.18499.22.camel@buesod1.americas.hpqcorp.net>
	 <20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>
	 <1396308332.18499.25.camel@buesod1.americas.hpqcorp.net>
	 <20140331170546.3b3e72f0.akpm@linux-foundation.org>
	 <1396371699.25314.11.camel@buesod1.americas.hpqcorp.net>
	 <CAHGf_=qsf6vN5k=-PLraG8Q_uU1pofoBDktjVH1N92o76xPadQ@mail.gmail.com>
	 <1396377083.25314.17.camel@buesod1.americas.hpqcorp.net>
	 <CAHGf_=rLLBDr5ptLMvFD-M+TPQSnK3EP=7R+27K8or84rY-KLA@mail.gmail.com>
	 <1396386062.25314.24.camel@buesod1.americas.hpqcorp.net>
	 <CAHGf_=rhXrBQSmDBJJ-vPxBbhjJ91Fh2iWe1cf_UQd-tCfpb2w@mail.gmail.com>
	 <20140401142947.927642a408d84df27d581e36@linux-foundation.org>
	 <CAHGf_=p70rLOYwP2OgtK+2b+41=GwMA9R=rZYBqRr1w_O5UnKA@mail.gmail.com>
	 <20140401144801.603c288674ab8f417b42a043@linux-foundation.org>
	 <1396389751.25314.26.camel@buesod1.americas.hpqcorp.net>
	 <20140401150843.13da3743554ad541629c936d@linux-foundation.org>
	 <534AD1EE.3050705@colorfullife.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, 2014-04-13 at 20:05 +0200, Manfred Spraul wrote:
> Hi Andrew,
> 
> On 04/02/2014 12:08 AM, Andrew Morton wrote:
> > Well, I'm assuming 64GB==infinity. It *was* infinity in the RHEL5 
> > timeframe, but infinity has since become larger so pickanumber. 
> 
> I think infinity is the right solution:
> The only common case where infinity is wrong would be Android - and 
> Android disables sysv shm entirely.
> 
> There are two patches:
> http://marc.info/?l=linux-kernel&m=139730332306185&q=raw

If you apply this one, please include the below, which updates a missing
definition for SHMALL.

diff --git a/include/uapi/linux/shm.h b/include/uapi/linux/shm.h
index d9497b7..0774ec4 100644
--- a/include/uapi/linux/shm.h
+++ b/include/uapi/linux/shm.h
@@ -9,14 +9,14 @@
 
 /*
  * SHMMAX, SHMMNI and SHMALL are upper limits are defaults which can
- * be increased by sysctl
+ * be decreased by sysctl.
  */
 
 #define SHMMAX ULONG_MAX		 /* max shared seg size (bytes) */
 #define SHMMIN 1			 /* min shared seg size (bytes) */
 #define SHMMNI 4096			 /* max num of segs system wide */
 #ifndef __KERNEL__
-#define SHMALL (SHMMAX/getpagesize()*(SHMMNI/16))
+#define SHMALL ULONG_MAX
 #endif
 #define SHMSEG SHMMNI			 /* max shared segs per process */
 


> http://marc.info/?l=linux-kernel&m=139727299800644&q=raw
> 
> Could you apply one of them?
> I wrote the first one, thus I'm biased which one is better.
> 
> --
>      Manfred


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

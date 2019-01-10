Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 55D288E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 15:44:36 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id q33so12642600qte.23
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 12:44:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b127sor36586224qkc.48.2019.01.10.12.44.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 12:44:35 -0800 (PST)
Message-ID: <1547153074.6911.8.camel@lca.pw>
Subject: Re: PROBLEM: syzkaller found / pool corruption-overwrite / page in
 user-area or NULL
From: Qian Cai <cai@lca.pw>
Date: Thu, 10 Jan 2019 15:44:34 -0500
In-Reply-To: <1547150339.2814.9.camel@linux.ibm.com>
References: 
	<t78EEfgpy3uIwPUvqvmuQEYEWKG9avWzjUD3EyR93Qaf_tfx1gqt4XplrqMgdxR1U9SsrVdA7G9XeUZacgUin0n6lBzoxJHVJ9Ko0yzzrxI=@protonmail.ch>
	 <1547150339.2814.9.camel@linux.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <jejb@linux.ibm.com>, Esme <esploit@protonmail.ch>, "dgilbert@interlog.com" <dgilbert@interlog.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, 2019-01-10 at 11:58 -0800, James Bottomley wrote:
> On Thu, 2019-01-10 at 19:12 +0000, Esme wrote:
> > Sorry for the resend some mail servers rejected the mime type.
> > 
> > Hi, I've been getting more into Kernel stuff lately and forged ahead
> > with some syzkaller bug finding.  I played with reducing it further
> > as you can see from the attached c code but am moving on and hope to
> > get better about this process moving forward as I'm still building
> > out my test systems/debugging tools.
> > 
> > Attached is the report and C repro that still triggers on a fresh git
> > pull as of a few minutes ago, if you need anything else please let me
> > know.
> > Esme
> > 
> > Linux syzkaller 5.0.0-rc1+ #5 SMP Tue Jan 8 20:39:33 EST 2019 x86_64
> > GNU/Linux
> 
> I'm not sure I'm reading this right, but it seems that a simple
> allocation inside block/scsi_ioctl.h
> 
> 	buffer = kzalloc(bytes, q->bounce_gfp | GFP_USER| __GFP_NOWARN);
> 
> (where bytes is < 4k) caused a slub padding check failure on free. 
> From the internal details, the freeing entity seems to be KASAN as part
> of its quarantine reduction (albeit triggered by this kzalloc).  I'm
> not remotely familiar with what KASAN is doing, but it seems the memory
> corruption problem is somewhere within the KASAN tracking?
> 
> I added linux-mm in case they can confirm this diagnosis or give me a
> pointer to what might be wrong in scsi.
> 

Well, need your .config and /proc/cmdline then.

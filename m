Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id C08CE8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:59:09 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id v72so6936936pgb.10
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 11:59:09 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id m75si4624897pga.432.2019.01.10.11.59.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 11:59:08 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id x0AJrYQ3073952
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:59:07 -0500
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2px9errune-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 14:59:07 -0500
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <jejb@linux.ibm.com>;
	Thu, 10 Jan 2019 19:59:06 -0000
Subject: Re: PROBLEM: syzkaller found / pool corruption-overwrite / page in
 user-area or NULL
From: James Bottomley <jejb@linux.ibm.com>
Date: Thu, 10 Jan 2019 11:58:59 -0800
In-Reply-To: <t78EEfgpy3uIwPUvqvmuQEYEWKG9avWzjUD3EyR93Qaf_tfx1gqt4XplrqMgdxR1U9SsrVdA7G9XeUZacgUin0n6lBzoxJHVJ9Ko0yzzrxI=@protonmail.ch>
References: 
	<t78EEfgpy3uIwPUvqvmuQEYEWKG9avWzjUD3EyR93Qaf_tfx1gqt4XplrqMgdxR1U9SsrVdA7G9XeUZacgUin0n6lBzoxJHVJ9Ko0yzzrxI=@protonmail.ch>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Message-Id: <1547150339.2814.9.camel@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Esme <esploit@protonmail.ch>, "dgilbert@interlog.com" <dgilbert@interlog.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Cc: "security@kernel.org" <security@kernel.org>

On Thu, 2019-01-10 at 19:12 +0000, Esme wrote:
> Sorry for the resend some mail servers rejected the mime type.
> 
> Hi, I've been getting more into Kernel stuff lately and forged ahead
> with some syzkaller bug finding.  I played with reducing it further
> as you can see from the attached c code but am moving on and hope to
> get better about this process moving forward as I'm still building
> out my test systems/debugging tools.
> 
> Attached is the report and C repro that still triggers on a fresh git
> pull as of a few minutes ago, if you need anything else please let me
> know.
> Esme
> 
> Linux syzkaller 5.0.0-rc1+ #5 SMP Tue Jan 8 20:39:33 EST 2019 x86_64
> GNU/Linux

I'm not sure I'm reading this right, but it seems that a simple
allocation inside block/scsi_ioctl.h

	buffer = kzalloc(bytes, q->bounce_gfp | GFP_USER| __GFP_NOWARN);

(where bytes is < 4k) caused a slub padding check failure on free. 
>From the internal details, the freeing entity seems to be KASAN as part
of its quarantine reduction (albeit triggered by this kzalloc).  I'm
not remotely familiar with what KASAN is doing, but it seems the memory
corruption problem is somewhere within the KASAN tracking?

I added linux-mm in case they can confirm this diagnosis or give me a
pointer to what might be wrong in scsi.

James

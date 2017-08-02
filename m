Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id ED6316B05CD
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 08:26:39 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e204so5634819wma.2
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 05:26:39 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k60si29895579wrc.52.2017.08.02.05.26.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 05:26:38 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v72CNmNQ139656
	for <linux-mm@kvack.org>; Wed, 2 Aug 2017 08:26:37 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2c3cf7pywk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 02 Aug 2017 08:26:36 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <imbrenda@linux.vnet.ibm.com>;
	Wed, 2 Aug 2017 13:26:34 +0100
Date: Wed, 2 Aug 2017 14:26:29 +0200
From: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm/ksm : Checksum calculation function change (jhash2
 -> crc32)
In-Reply-To: <20170801200550.GB24406@redhat.com>
References: <1501589255-9389-1-git-send-email-solee@os.korea.ac.kr>
	<20170801200550.GB24406@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20170802142629.578064f7@p-imbrenda.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: leesioh <solee@os.korea.ac.kr>, akpm@linux-foundation.org, mingo@kernel.org, zhongjiang@huawei.com, minchan@kernel.org, arvind.yadav.cs@gmail.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org

On Tue, 1 Aug 2017 22:05:50 +0200
Andrea Arcangeli <aarcange@redhat.com> wrote:

> On Tue, Aug 01, 2017 at 09:07:35PM +0900, leesioh wrote:
> > In ksm, the checksum values are used to check changes in page
> > content and keep the unstable tree more stable. KSM implements
> > checksum calculation with jhash2 hash function. However, because
> > jhash2 is implemented in software, it consumes high CPU cycles
> > (about 26%, according to KSM thread profiling results)
> > 
> > To reduce CPU consumption, this commit applies the crc32 hash
> > function which is included in the SSE4.2 CPU instruction set.
> > This can significantly reduce the page checksum overhead as follows.
> > 
> > I measured checksum computation 300 times to see how fast crc32 is
> > compared to jhash2. With jhash2, the average checksum calculation
> > time is about 3460ns, and with crc32, the average checksum
> > calculation time is 888ns. This is about 74% less than jhash2.  
> 
> crc32 may create more false positives than jhash2. crc32 only
> guarantees a different value in return if fewer than N bit
> changes. False positives in crc32 comparison, would result in more
> unstable pages being added to the unstable tree, and if they're
> changing as result of false positives it may make the unstable tree
> more unstable leading to missed merges (in addition to the overhead of
> adding those to the unstable tree in the first place and in addition
> of risking an immediate cow post merge which would slowdown apps even
> more).
> 
> I think if somebody wants a crc instead of a more proper hash (that is
> less likely to generate false positives if a couple of bits changes)
> it should be an option in sysfs not enabled by default, but overall I
> think it's not worth this change for a downgrade to crc. There's the
> risk an admin thinks it's going to make things runs faster because KSM
> CPU utilization decreases, but missing the risk of increased CoWs in
> app context or missed merges because of higher instability in the
> unstable tree.

that's true, but it's possible that all the extra work due to
additional collisions could still be less than the time saved with a
faster checksum. Also, even within the same architecture, different
checksums can have different performances depending on CPU vendor and
model. I would still let the admin (or ksmtuned) choose.

> Still deploying hardware accelleration in the KSM hash is a
> interesting idea that I don't recall has been tried. Could you try to
> benchmark in userland (or kernel if you wish) software jhash2 vs
> CONFIG_CRYPTO_SHA1_SSSE3 or CONFIG_CRYPTO_GHASH_CLMUL_NI_INTEL instead
> of the accellerated crc?  (I don't know if GHASH API can fit our use
> case though, but accellerated SHA1 sure would fit).  I suppose they'll
> be slower than crc32, and probably slower than jhash2 too, however I
> can't be sure by just thinking about it.
>
> We've to also keep the floating point save and restore into account in
> the real world, where ksm schedules often and may run interleaved in
> the same CPU where an app uses the fpu a lot in userland (if the
> interleaved app doesn't use the fpu in userland it won't create
> overhead).

that is also true, although some CPUs have basic (and not-so-basic)
crypto functions baked in, so no need to save or restore FPU registers
in those cases. 


best regards

Claudio

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

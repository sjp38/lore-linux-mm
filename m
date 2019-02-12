Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20D2EC282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 17:18:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2BD6222C0
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 17:18:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="cAWqpD7p"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2BD6222C0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9E05F8E0003; Tue, 12 Feb 2019 12:18:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98FB98E0001; Tue, 12 Feb 2019 12:18:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 857DF8E0003; Tue, 12 Feb 2019 12:18:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5EB068E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 12:18:38 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id 83so91305ybz.5
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:18:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=VmxsxuHb/nNuCt+dhukfv0Psv77KAOzs+jgh6bmnEkg=;
        b=ikDapgygian3zlOaaPDP4hvjsK8J9rXa/JLrlwAnaAvQqDdiRn2v64fL2q4qux3zns
         PoRLxBSx+fVu0Qr3xQVEitnsisc+T7FM3q4JKHdIL85hdo1hywqYDwnaBLQDKqSfwOSq
         rQBPHlBJQZMkc3uuIP5wwE7Txx6tvrr8JUUceO7pFeTqulkluRx0tf3dqmc3psWI6ZAU
         2s/UgDKlhQTM4x1i8EW8fnZOB9o4H41kAA77EZCWU/X/XfWLAT6RWxMQiqVStew/PT6u
         gaFJJZfQAbRFZkeyezD2dk30y4zTBhFfdDTIp3ooXu9gfS3w8YupcO8rf30DTxchv0of
         n01Q==
X-Gm-Message-State: AHQUAuYd9RNLHD0+agoA+JhdqsqNpTcGLXftHjMl+WUG+yLLiQba7sVS
	ihRXra4kTrJR7MooxOnMBevNjo6q2fHE0NSEktKxD+Dp1QNVk/Qt7GfzbH2oQV3bn4a20RBthT0
	2eAFo54d/7AvjLgv6exXdXGhBlJnqsXiuoBeviptpxivauZJ4DJ9stU6NykZRj2npJg==
X-Received: by 2002:a25:d6ce:: with SMTP id n197mr3753984ybg.313.1549991918054;
        Tue, 12 Feb 2019 09:18:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbJDPjn4F2beTxe3b3J/gtrC1vzwbPVKuEtgZdxi1GuUn/uc616G5CSJe/lC2XVzeEfNoNs
X-Received: by 2002:a25:d6ce:: with SMTP id n197mr3753921ybg.313.1549991917349;
        Tue, 12 Feb 2019 09:18:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549991917; cv=none;
        d=google.com; s=arc-20160816;
        b=QWjT3GCZGbEsq66VQ8wUSy5z1RWZXuEH/aUCvK7FI8/Hlgpd0TpXB/BugzTUsS1fFq
         8hcuE7Cqiz+cSYoOZleTUM3Hn6qv0IMgiGyVKLFkhIUOsegPR2EP54FKoz+2l58Mr8Vj
         miJzBe3hwssx3Ebl6/PBA1e2zfO0LCSDwHcJtbFHxiPIFXE3dFs9l9z1vPZIcd/koZos
         S4c/IpYK72rN/8uc7m5Z76Yf1yyWk/GcOzokbGYCkJlGcyKRwIP9fe+gz7YntEOVFo4O
         AKA/otFlDSlvE0MKk5t7RSCZ2rCFrwYEQukDilM6PgrRy8EpHa/v7qQ90NnKsSbsRkrc
         Lffg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=VmxsxuHb/nNuCt+dhukfv0Psv77KAOzs+jgh6bmnEkg=;
        b=YSdwKCEbM/3JaN7KpGb8PlDKcANAL7Z/Td0HDqAbLvb9ydFWSpcq5IOHMgNb4+b4ap
         oWViWIdVcTOEabu5Fw4BlVbrwIm2sQAgfYj9iWImbwxPfNRrYhuSL9ARkriR/EMpm8mw
         kXGBJqdx7w1mFiCwgMc7cl2/kpU5lz7UIi/+9MmVgP5rzlAKeHVIGaec6iO1e/9eir+K
         469/eOeHE1Y7ItqqGcAG1ZbGkkGiPwZ9fLhJWnMECIKoF3SFoLNpUaUnxz7F2MZhpPG9
         y6H6n+ijdnK1M5KaHB3+M9ZSy/5EaWOvUEtQC5v1EXbc3mIORInOUQHTYiVAt3ecPm7r
         QOeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=cAWqpD7p;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id q67si6503873ywe.151.2019.02.12.09.18.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Feb 2019 09:18:37 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=cAWqpD7p;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1CH9Ntn177072;
	Tue, 12 Feb 2019 17:18:25 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=VmxsxuHb/nNuCt+dhukfv0Psv77KAOzs+jgh6bmnEkg=;
 b=cAWqpD7pHuas7OAJKc8a16t6RRPPDvFeCUPvPLZSU1DV0m2niD9UyXU3JG8AYTXb3UxD
 cosODj0IWQ1vAiERykYUlPqGoibt95GRbbgdi4RD4ABybKDbmwmFElonnj8b4ddSz/QK
 6nleplkWrOjhJNgKzwYLwOHDzLMxbXqaBJoPzKcoD/svMYyNKKM/JoQzurdj0tdkZKl8
 HDDbK5VE+Z/Zj+rEul6f03Zbw6ns6ncUl17Yj3kLDMrDh4Fh7x3jWua+z1d3wCExktWc
 EJfg2BAMbjN87Ls8vB3umLoTeN1KX8AHFvGt7O1pcQtaYUJIMPmAjNOUFJUjqd0m/RDL ww== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by aserp2130.oracle.com with ESMTP id 2qhre5da28-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Feb 2019 17:18:25 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1CHIOKL026587
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Feb 2019 17:18:24 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1CHIKOJ029838;
	Tue, 12 Feb 2019 17:18:20 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 12 Feb 2019 09:18:20 -0800
Date: Tue, 12 Feb 2019 12:18:40 -0500
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Christopher Lameter <cl@linux.com>
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>,
        Daniel Jordan <daniel.m.jordan@oracle.com>, jgg@ziepe.ca,
        akpm@linux-foundation.org, dave@stgolabs.net, jack@suse.cz,
        linux-mm@kvack.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org,
        linuxppc-dev@lists.ozlabs.org, linux-fpga@vger.kernel.org,
        linux-kernel@vger.kernel.org, alex.williamson@redhat.com,
        paulus@ozlabs.org, benh@kernel.crashing.org, mpe@ellerman.id.au,
        hao.wu@intel.com, atull@kernel.org, mdf@kernel.org
Subject: Re: [PATCH 2/5] vfio/spapr_tce: use pinned_vm instead of locked_vm
 to account pinned pages
Message-ID: <20190212171839.env4rnjwdjyips6z@ca-dmjordan1.us.oracle.com>
References: <20190211224437.25267-1-daniel.m.jordan@oracle.com>
 <20190211224437.25267-3-daniel.m.jordan@oracle.com>
 <ee4d14db-05c3-6208-503c-16e287fa78eb@ozlabs.ru>
 <01000168e29daf0a-cb3a9394-e3dd-4d88-ad3c-31df1f9ec052-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <01000168e29daf0a-cb3a9394-e3dd-4d88-ad3c-31df1f9ec052-000000@email.amazonses.com>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9165 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=18 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902120122
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 04:50:11PM +0000, Christopher Lameter wrote:
> On Tue, 12 Feb 2019, Alexey Kardashevskiy wrote:
> 
> > Now it is 3 independent accesses (actually 4 but the last one is
> > diagnostic) with no locking around them. Why do not we need a lock
> > anymore precisely? Thanks,
> 
> Updating a regular counter is racy and requires a lock. It was converted
> to be an atomic which can be incremented without a race.

Yes, though Alexey may have meant that the multiple reads of the atomic in
decrement_pinned_vm are racy.  It only matters when there's a bug that would
make the counter go negative, but it's there.

And FWIW the debug print in try_increment_pinned_vm is also racy.

This fixes all that.  It doesn't try to correct the negative pinned_vm as the
old code did because it's already a bug and adjusting the value by the negative
amount seems to do nothing but make debugging harder.

If it's ok, I'll respin the whole series this way (another point for common
helper)

diff --git a/drivers/vfio/vfio_iommu_spapr_tce.c b/drivers/vfio/vfio_iommu_spapr_tce.c
index f47e020dc5e4..b79257304de6 100644
--- a/drivers/vfio/vfio_iommu_spapr_tce.c
+++ b/drivers/vfio/vfio_iommu_spapr_tce.c
@@ -53,25 +53,24 @@ static long try_increment_pinned_vm(struct mm_struct *mm, long npages)
 		atomic64_sub(npages, &mm->pinned_vm);
 	}
 
-	pr_debug("[%d] RLIMIT_MEMLOCK +%ld %ld/%lu%s\n", current->pid,
-			npages << PAGE_SHIFT,
-			atomic64_read(&mm->pinned_vm) << PAGE_SHIFT,
-			rlimit(RLIMIT_MEMLOCK), ret ? " - exceeded" : "");
+	pr_debug("[%d] RLIMIT_MEMLOCK +%ld %lld/%lu%s\n", current->pid,
+			npages << PAGE_SHIFT, pinned << PAGE_SHIFT,
+			lock_limit, ret ? " - exceeded" : "");
 
 	return ret;
 }
 
 static void decrement_pinned_vm(struct mm_struct *mm, long npages)
 {
+	s64 pinned;
+
 	if (!mm || !npages)
 		return;
 
-	if (WARN_ON_ONCE(npages > atomic64_read(&mm->pinned_vm)))
-		npages = atomic64_read(&mm->pinned_vm);
-	atomic64_sub(npages, &mm->pinned_vm);
-	pr_debug("[%d] RLIMIT_MEMLOCK -%ld %ld/%lu\n", current->pid,
-			npages << PAGE_SHIFT,
-			atomic64_read(&mm->pinned_vm) << PAGE_SHIFT,
+	pinned = atomic64_sub_return(npages, &mm->pinned_vm);
+	WARN_ON_ONCE(pinned < 0);
+	pr_debug("[%d] RLIMIT_MEMLOCK -%ld %lld/%lu\n", current->pid,
+			npages << PAGE_SHIFT, pinned << PAGE_SHIFT,
 			rlimit(RLIMIT_MEMLOCK));
 }
 


Return-Path: <SRS0=rDiK=SJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA29AC282DE
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 22:11:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C68120880
	for <linux-mm@archiver.kernel.org>; Sun,  7 Apr 2019 22:11:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="VF6J7VpL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C68120880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C86F26B0005; Sun,  7 Apr 2019 18:11:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0C1E6B0006; Sun,  7 Apr 2019 18:11:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AACF76B0007; Sun,  7 Apr 2019 18:11:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9196B0005
	for <linux-mm@kvack.org>; Sun,  7 Apr 2019 18:11:14 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id q23so7035280otk.10
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 15:11:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=B2XZYc73eRD7vceltyVRxYxMZptJ0KGjDTZjSsKaM94=;
        b=obwELRKzLD/cDi+QibewaIvckyqn8hcUwqnM3CdWATY9Y+QEvI3/ovm0eCvwjN+fiu
         HkRkIcVLGbciYFWKPafGynAxm5AqNkE0fRXuz4UHZ+CVO3uI5OSDsf/6t19SA9ri/p+J
         lu+wwI9Fx8OBawbndK1xGRkIac0fa66lQYhB2e99RCJdm6KorVWrx4sTReUVbDXF/+X8
         dpOrPHn8NUknWg/ybMBP3W6l3XoG7I8r7zzJL+PRRD3qKKSVbPuxfqQAyWaHyEclRmbQ
         35kEHtFT+AYk7dITH9HUJNT8wyAXnESz9BciX0ZriAOLfh1y7FMbVoYmxXXZsSf5qIJq
         gKxQ==
X-Gm-Message-State: APjAAAXkntoDeQrn4e1nxCNzJzMjKCeUb3wu4hCunCp3wG3cGHdgYYFq
	on8Ffm44C/61YO20FyQcsuXmW+p2O/JNAGup3O/mw/xUrnQ2Q/Q0TpdWX4QNi8N0ZX1jR9oXgvF
	wntoz3z1x8V9Uo1Q0IRbtwk69f/OM//NA2UraGGDW7Ql8Pf1z1syS3CfbhA3yyKr+ig==
X-Received: by 2002:a9d:5f06:: with SMTP id f6mr17366132oti.18.1554675074120;
        Sun, 07 Apr 2019 15:11:14 -0700 (PDT)
X-Received: by 2002:a9d:5f06:: with SMTP id f6mr17366104oti.18.1554675073437;
        Sun, 07 Apr 2019 15:11:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554675073; cv=none;
        d=google.com; s=arc-20160816;
        b=ETy/sIhqmmCxWsSM8rge5xgH0VIk+RNKTCVTWtjrTdu2Gd7599E8kIn7REPMn2XiGB
         yXCFnGpCOpzVnsTjxZntSgYf4AlGMzRGaYJbFzxaiRZBr0iEJi/4mWwphzb/9txqx+dr
         irqOa+xY+F8uWEPuAx23dJEARhEv03jl7Im0GScfez505MX5tEOOYaaU4/V/y3KSnxF6
         D3/Jk1yghl4q3cIbaHLr5ZeBrPKcTtCGi6Fv1iOd/12WodH8MsspwSVfM6mpaMoK09GS
         6W8KCFN+arGaasVMjPA3Dz5K1RMh9a34zWn694dj/YxKWGhoHvCLOzwYdvMNfHBogIcS
         SmEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=B2XZYc73eRD7vceltyVRxYxMZptJ0KGjDTZjSsKaM94=;
        b=Aq6valSs8lLMH7oBrob6qTCWJ2xFOm76Vm83gOkCl5zbNCDEi2RmKkEIvGX50SExA8
         or99ESaaB52jtZdfR9EhQG4N3bf8wcdBAgjUHrhsVgw0TpxbQHpjnV6QiiTXnfg5V+4H
         SQBBBPXDNq7otu/583r8n6aNV5p6vfa9SFoE4WauP48L885WDRyAuzfMTjyDvruOPtoi
         69489z7nJcSTFEj/NPjZbiB1FOThngRwsi+anuPl4OKCYjVx62GAK8wQV0LKogs4yuT+
         J+eWk4AWeDmOR80vYUUzk/czuAecMcagQxtSa7Uxg/uXZ1E6xZamG5OkDkpCDHVVKdRo
         FI+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=VF6J7VpL;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r83sor3562749oia.30.2019.04.07.15.11.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 07 Apr 2019 15:11:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=VF6J7VpL;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=B2XZYc73eRD7vceltyVRxYxMZptJ0KGjDTZjSsKaM94=;
        b=VF6J7VpLiFG+tX7uSQBIb+AwaLMM5daXTCJr5O14/07I+crMC/7CyhhDhw/rkhgzqV
         QAJpzGmLF77WW5GGQgOi7zXJLDOUf9PWcJXZpAaDnR8G2Z/o32w5PyVXb2/17NUKOENd
         ILp3C+qJyDufmz/H2FvScxkpoEoX8y3/OKQkd3xj2xNV8GjV5iFpzzmF+UKZJX1J+Nbv
         +s8qytEbKUXRw946ci+uDxo4I/DMq3otb4OcjI6kzqUlEJ+XYDKXR8Rkk3WUGRzttS9r
         3gvfgcy6yRVczoPA5o6/ZvBoApQtsCN3QuyBLTFSXyHZBeidoj1Uji54NX/l7khGIYFi
         58RA==
X-Google-Smtp-Source: APXvYqzY6+cyTHrSoY4urPHyhyziXZg+NKTZb0BCBZ46NSBkQJtTlIpQKITlrqnG9yYnwNxu42BStWrEHG+Tle46O5A=
X-Received: by 2002:aca:f581:: with SMTP id t123mr14992918oih.0.1554675072260;
 Sun, 07 Apr 2019 15:11:12 -0700 (PDT)
MIME-Version: 1.0
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-7-git-send-email-anshuman.khandual@arm.com>
 <ea5567c7-caad-8a4e-7c6f-cec4b772a526@arm.com> <0d72db39-e20d-1cbd-368e-74dda9b6c936@arm.com>
 <CAPcyv4h5YskvjR306FsHnVHpPjnT4s2JPJXgk6CxiMz8bjhqkg@mail.gmail.com> <a16a9867-7019-10ab-1901-c114bcd8712b@arm.com>
In-Reply-To: <a16a9867-7019-10ab-1901-c114bcd8712b@arm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 7 Apr 2019 15:11:00 -0700
Message-ID: <CAPcyv4j0Z2ASeJGgS18Bpgr_2F8XdZdCq4T9W5fgkG1oWKtNHg@mail.gmail.com>
Subject: Re: [PATCH 6/6] arm64/mm: Enable ZONE_DEVICE
To: Robin Murphy <robin.murphy@arm.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, 
	Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, 
	Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, james.morse@arm.com, 
	Mark Rutland <mark.rutland@arm.com>, cpandya@codeaurora.org, arunks@codeaurora.org, 
	osalvador@suse.de, Logan Gunthorpe <logang@deltatee.com>, 
	David Hildenbrand <david@redhat.com>, cai@lca.pw, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	"Weiny, Ira" <ira.weiny@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 4, 2019 at 2:47 AM Robin Murphy <robin.murphy@arm.com> wrote:
>
> On 04/04/2019 06:04, Dan Williams wrote:
> > On Wed, Apr 3, 2019 at 9:42 PM Anshuman Khandual
> > <anshuman.khandual@arm.com> wrote:
> >>
> >>
> >>
> >> On 04/03/2019 07:28 PM, Robin Murphy wrote:
> >>> [ +Dan, Jerome ]
> >>>
> >>> On 03/04/2019 05:30, Anshuman Khandual wrote:
> >>>> Arch implementation for functions which create or destroy vmemmap mapping
> >>>> (vmemmap_populate, vmemmap_free) can comprehend and allocate from inside
> >>>> device memory range through driver provided vmem_altmap structure which
> >>>> fulfils all requirements to enable ZONE_DEVICE on the platform. Hence just
> >>>
> >>> ZONE_DEVICE is about more than just altmap support, no?
> >>
> >> Hot plugging the memory into a dev->numa_node's ZONE_DEVICE and initializing the
> >> struct pages for it has stand alone and self contained use case. The driver could
> >> just want to manage the memory itself but with struct pages either in the RAM or
> >> in the device memory range through struct vmem_altmap. The driver may not choose
> >> to opt for HMM, FS DAX, P2PDMA (use cases of ZONE_DEVICE) where it may have to
> >> map these pages into any user pagetable which would necessitate support for
> >> pte|pmd|pud_devmap.
> >
> > What's left for ZONE_DEVICE if none of the above cases are used?
> >
> >> Though I am still working towards getting HMM, FS DAX, P2PDMA enabled on arm64,
> >> IMHO ZONE_DEVICE is self contained and can be evaluated in itself.
> >
> > I'm not convinced. What's the specific use case.
>
> The fundamental "roadmap" reason we've been doing this is to enable
> further NVDIMM/pmem development (libpmem/Qemu/etc.) on arm64. The fact
> that ZONE_DEVICE immediately opens the door to the various other stuff
> that the CCIX folks have interest in is a definite bonus, so it would
> certainly be preferable to get arm64 on par with the current state of
> things rather than try to subdivide the scope further.
>
> I started working on this from the ZONE_DEVICE end, but got bogged down
> in trying to replace my copied-from-s390 dummy hot-remove implementation
> with something proper. Anshuman has stepped in to help with hot-remove
> (since we also have cloud folks wanting that for its own sake), so is
> effectively coming at the problem from the opposite direction, and I'll
> be the first to admit that we've not managed the greatest job of meeting
> in the middle and coordinating our upstream story; sorry about that :)
>
> Let me freshen up my devmap patches and post them properly, since that
> discussion doesn't have to happen in the context of hot-remove; they're
> effectively just parallel dependencies for ZONE_DEVICE.

Sounds good. It's also worth noting that Ira's recent patches for
supporting get_user_pages_fast() for "longterm" pins relies on
PTE_DEVMAP to determine when fast-GUP is safe to proceed, or whether
it needs to fall back to slow-GUP. So it really is the case that
"devmap" support is an assumption for ZONE_DEVICE.


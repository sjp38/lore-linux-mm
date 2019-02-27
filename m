Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17DE9C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 05:32:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A301D218E0
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 05:32:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A301D218E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD3888E0003; Wed, 27 Feb 2019 00:32:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D823F8E0001; Wed, 27 Feb 2019 00:32:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C982F8E0003; Wed, 27 Feb 2019 00:32:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9F2BE8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 00:32:43 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id x63so12444372qka.5
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 21:32:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=MMs4btRfFMDn2gbDBDla7ALCCRy9T1gjmgsGu85YaII=;
        b=LlhSw4g9mO9l3MuufVW0mcRUUbjdF/kCXkvFlVOO3oEbi0ulUX1MzGQEEWK2f5WOFP
         EaG5DpnIAl81I1ticlFG0Hx8lt6HpSA8OOIS2d9/xXV/6lbsEqevt6ofkoNw+QmPmHUq
         hI6ycRlFxqgGLT+FTjeOOqU9++6Uef6amaZYBfQZNp2kcn7d1Gw/A17KjVMbGUr2KFcy
         B+49W+NzTBn5JlsfvoXr2QzEHHKpEaXpy/xiJv8Z3oaVU14UKb/RWFaCo+hK8R+k0wre
         c9FWNEQHGdINoudTPmGg7zohFRWZb37zpxbmyfPVI3Wmp22v1OHAM3F2B9h8tfFXe6Zg
         SfJg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dyoung@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXjGe2Jg+BrEa/G3AHTnamToNkUMMc90kntda/7xcBfJkuQgs3l
	oW0Wwg2EChZbxxVzgVj7lJ9Yf3iedcHO8Vn6gBnWfufpQ1KB0oBjCCbKlSLaoeyWJbnA/I42PZC
	dZgjbT7L56MEYpHcHv6/l7Ex9LArKoLvKwO+3uNg0eDjVvh3l5DBug68z+ifAZasKFg==
X-Received: by 2002:a05:620a:1253:: with SMTP id a19mr851064qkl.271.1551245563346;
        Tue, 26 Feb 2019 21:32:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IatHG8a3qL/RLDFp4VJTtWLnupohlYbd9HRbCFwSsm29NrY6tshWRgwRTxPAM7+hiHhx4q6
X-Received: by 2002:a05:620a:1253:: with SMTP id a19mr851026qkl.271.1551245562408;
        Tue, 26 Feb 2019 21:32:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551245562; cv=none;
        d=google.com; s=arc-20160816;
        b=vSOgIr04ITCxwjQK5q46VX8ykdnvT7FlEcG7v3M7PU5pSghv1Y6rpjd290dF2SwN3e
         cUelMqGQFsX/dvocQ6RxRCMzhV+DzkBlsds0VeIENoGtle5XLvx4L9noxg7tHIjY1KOp
         vT5jyE3UXVBaa8hJx1KMKJlMh9RLMx9bjb+cmWu4Wquorh5DYkVof9iYDvORVBKm0N/D
         yEMQu9JWL/P9/sDTYZcDg3LjyQn8LkfVEiWYvfPBtS6/UIhFDqb7mKwqJdb0UN9voWGZ
         AG4Sr9CowJIYRNfnb3tiG3bLtEsNQQD8OgulxbB38/vkeXrSwrIkfd0olMio/B0g0PE8
         GOPA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=MMs4btRfFMDn2gbDBDla7ALCCRy9T1gjmgsGu85YaII=;
        b=AK3U20p2GQgBpjwfctur4Xb/F2ixO8roCEl7TmOEyef93bN33x7neN83lbLXFwTVwo
         j2wOepwVNlysJhvpkcOylM+6mq8SERwr5SOwcajOVpmwTF69GFH5wKfKEMNDIiBct3n9
         Y8rfnr1t+POWIbtulsF94GcwOsGSxPpsyAee4Ohn9L9ZpF2in6TQ1JKjPqFnZx9Z+4sH
         9Orka231Im904qv0lUV0qwyUvHGwvKIbjgpCqpbl//g7wSFJJjMhKyOG6r29lgbbbrwB
         ZxyV7fmyvokE7g5+Sdn9nxBxGtfl+FV6jE4M+QNt6b4ElbHg0zWpDTVze1WG2GJ+ACDP
         9Jxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dyoung@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k2si127412qkl.42.2019.02.26.21.32.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Feb 2019 21:32:42 -0800 (PST)
Received-SPF: pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dyoung@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=dyoung@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 95CFAC07EFC5;
	Wed, 27 Feb 2019 05:32:40 +0000 (UTC)
Received: from dhcp-128-65.nay.redhat.com (ovpn-12-110.pek2.redhat.com [10.72.12.110])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 017B2604CD;
	Wed, 27 Feb 2019 05:32:18 +0000 (UTC)
Date: Wed, 27 Feb 2019 13:32:14 +0800
From: Dave Young <dyoung@redhat.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org, devel@linuxdriverproject.org,
	linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org,
	xen-devel@lists.xenproject.org,
	kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com,
	Alexander Duyck <alexander.h.duyck@linux.intel.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Arnd Bergmann <arnd@arndb.de>, Baoquan He <bhe@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Christian Hansen <chansen3@cisco.com>,
	David Rientjes <rientjes@google.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	Jonathan Corbet <corbet@lwn.net>, Juergen Gross <jgross@suse.com>,
	Julien Freche <jfreche@vmware.com>, Kairui Song <kasong@redhat.com>,
	Kazuhito Hagio <k-hagio@ab.jp.nec.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Konstantin Khlebnikov <koct9i@gmail.com>,
	"K. Y. Srinivasan" <kys@microsoft.com>,
	Len Brown <len.brown@intel.com>, Lianbo Jiang <lijiang@redhat.com>,
	Matthew Wilcox <willy@infradead.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Miles Chen <miles.chen@mediatek.com>, Nadav Amit <namit@vmware.com>,
	Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
	Omar Sandoval <osandov@fb.com>, Pankaj gupta <pagupta@redhat.com>,
	Pavel Machek <pavel@ucw.cz>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	"Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Stefano Stabellini <sstabellini@kernel.org>,
	Stephen Hemminger <sthemmin@microsoft.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Vitaly Kuznetsov <vkuznets@redhat.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Xavier Deguillard <xdeguillard@vmware.com>
Subject: Re: [PATCH v2 0/8] mm/kdump: allow to exclude pages that are
 logically offline
Message-ID: <20190227053214.GA12302@dhcp-128-65.nay.redhat.com>
References: <20181122100627.5189-1-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181122100627.5189-1-david@redhat.com>
User-Agent: Mutt/1.9.5 (2018-04-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 27 Feb 2019 05:32:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 11/22/18 at 11:06am, David Hildenbrand wrote:
> Right now, pages inflated as part of a balloon driver will be dumped
> by dump tools like makedumpfile. While XEN is able to check in the
> crash kernel whether a certain pfn is actually backed by memory in the
> hypervisor (see xen_oldmem_pfn_is_ram) and optimize this case, dumps of
> virtio-balloon, hv-balloon and VMWare balloon inflated memory will
> essentially result in zero pages getting allocated by the hypervisor and
> the dump getting filled with this data.
> 
> The allocation and reading of zero pages can directly be avoided if a
> dumping tool could know which pages only contain stale information not to
> be dumped.
> 
> Also for XEN, calling into the kernel and asking the hypervisor if a
> pfn is backed can be avoided if the duming tool would skip such pages
> right from the beginning.
> 
> Dumping tools have no idea whether a given page is part of a balloon driver
> and shall not be dumped. Esp. PG_reserved cannot be used for that purpose
> as all memory allocated during early boot is also PG_reserved, see
> discussion at [1]. So some other way of indication is required and a new
> page flag is frowned upon.
> 
> We have PG_balloon (MAPCOUNT value), which is essentially unused now. I
> suggest renaming it to something more generic (PG_offline) to mark pages as
> logically offline. This flag can than e.g. also be used by virtio-mem in
> the future to mark subsections as offline. Or by other code that wants to
> put pages logically offline (e.g. later maybe poisoned pages that shall
> no longer be used).
> 
> This series converts PG_balloon to PG_offline, allows dumping tools to
> query the value to detect such pages and marks pages in the hv-balloon
> and XEN balloon properly as PG_offline. Note that virtio-balloon already
> set pages to PG_balloon (and now PG_offline).
> 
> Please note that this is also helpful for a problem we were seeing under
> Hyper-V: Dumping logically offline memory (pages kept fake offline while
> onlining a section via online_page_callback) would under some condicions
> result in a kernel panic when dumping them.
> 
> As I don't have access to neither XEN nor Hyper-V nor VMWare installations,
> this was only tested with the virtio-balloon and pages were properly
> skipped when dumping. I'll also attach the makedumpfile patch to this
> series.
> 
> [1] https://lkml.org/lkml/2018/7/20/566
> 
> v1 -> v2:
> - "kexec: export PG_offline to VMCOREINFO"
> -- Add description why it is exported as a macro
> - "vmw_balloon: mark inflated pages PG_offline"
> -- Use helper function + adapt comments
> - "PM / Hibernate: exclude all PageOffline() pages"
> -- Perform the check separate from swsusp checks.
> - Added RBs/ACKs
> 
> 
> David Hildenbrand (8):
>   mm: balloon: update comment about isolation/migration/compaction
>   mm: convert PG_balloon to PG_offline
>   kexec: export PG_offline to VMCOREINFO
>   xen/balloon: mark inflated pages PG_offline
>   hv_balloon: mark inflated pages PG_offline
>   vmw_balloon: mark inflated pages PG_offline
>   PM / Hibernate: use pfn_to_online_page()
>   PM / Hibernate: exclude all PageOffline() pages
> 
>  Documentation/admin-guide/mm/pagemap.rst |  9 ++++---
>  drivers/hv/hv_balloon.c                  | 14 ++++++++--
>  drivers/misc/vmw_balloon.c               | 32 ++++++++++++++++++++++
>  drivers/xen/balloon.c                    |  3 +++
>  fs/proc/page.c                           |  4 +--
>  include/linux/balloon_compaction.h       | 34 +++++++++---------------
>  include/linux/page-flags.h               | 11 +++++---
>  include/uapi/linux/kernel-page-flags.h   |  2 +-
>  kernel/crash_core.c                      |  2 ++
>  kernel/power/snapshot.c                  | 17 +++++++-----
>  tools/vm/page-types.c                    |  2 +-
>  11 files changed, 90 insertions(+), 40 deletions(-)
> 
> -- 
> 2.17.2
> 

This series have been in -next for some days, could we get this in
mainline? 

Andrew, do you have plan about them, maybe next release?

Thanks
Dave


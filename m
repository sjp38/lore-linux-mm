Return-Path: <SRS0=C2dt=WH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4F59C433FF
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 23:07:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8ACD12087B
	for <linux-mm@archiver.kernel.org>; Sun, 11 Aug 2019 23:07:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="GjochqX+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8ACD12087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CDF56B0005; Sun, 11 Aug 2019 19:07:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 07E716B0006; Sun, 11 Aug 2019 19:07:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB0966B0007; Sun, 11 Aug 2019 19:07:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0025.hostedemail.com [216.40.44.25])
	by kanga.kvack.org (Postfix) with ESMTP id C40F46B0006
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 19:07:26 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 53E5345BB
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 23:07:26 +0000 (UTC)
X-FDA: 75811685292.03.dolls30_7b0be76471b2c
X-HE-Tag: dolls30_7b0be76471b2c
X-Filterd-Recvd-Size: 5698
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com [216.228.121.64])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sun, 11 Aug 2019 23:07:25 +0000 (UTC)
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d509fb60000>; Sun, 11 Aug 2019 16:07:34 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Sun, 11 Aug 2019 16:07:24 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Sun, 11 Aug 2019 16:07:24 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Sun, 11 Aug
 2019 23:07:23 +0000
Subject: Re: [RFC PATCH v2 15/19] mm/gup: Introduce vaddr_pin_pages()
To: <ira.weiny@intel.com>, Andrew Morton <akpm@linux-foundation.org>
CC: Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>, Jan Kara <jack@suse.cz>, Theodore Ts'o
	<tytso@mit.edu>, Michal Hocko <mhocko@suse.com>, Dave Chinner
	<david@fromorbit.com>, <linux-xfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <linux-nvdimm@lists.01.org>,
	<linux-ext4@vger.kernel.org>, <linux-mm@kvack.org>
References: <20190809225833.6657-1-ira.weiny@intel.com>
 <20190809225833.6657-16-ira.weiny@intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <88d82639-c0b2-0b35-1919-999a8438031c@nvidia.com>
Date: Sun, 11 Aug 2019 16:07:23 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809225833.6657-16-ira.weiny@intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565564854; bh=WyN+cqUy4NONmSoVEoC5zyApgJufQNRRkmxYAmxiNRk=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=GjochqX+orN7s3BQGomPrZQyWc/568hzhVWT8sDxI6ycL8n3NJRfjYVyxlilSkFJV
	 0v1gr7a1sg2wL7PQ7Q0Dcubx1ogIn8Ke72whU/7rqtGuRqPq7C+Ov/M2GpkOhsvG7D
	 prYV07lPVe1n7zXbUFOOqu0O+zmZFD4o9ZwEYryqx80zMRNZ+bq7HCwxmmVbIxjO2a
	 eyfVpsIxVN8KjqFFKHnKr50U23pYiJqe16sEcZFBVMMPBbuIaXUFHzc2oRYO+Hbvbq
	 BtKCArw8N2g27OxonpaIrJUWZPBJhIbV9JVwYzpariVg0rZ5RNb/Q9Z0jeOeGL3ylM
	 qgEDDHrL4QwYQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/9/19 3:58 PM, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> The addition of FOLL_LONGTERM has taken on additional meaning for CMA
> pages.
> 
> In addition subsystems such as RDMA require new information to be passed
> to the GUP interface to track file owning information.  As such a simple
> FOLL_LONGTERM flag is no longer sufficient for these users to pin pages.
> 
> Introduce a new GUP like call which takes the newly introduced vaddr_pin
> information.  Failure to pass the vaddr_pin object back to a vaddr_put*
> call will result in a failure if pins were created on files during the
> pin operation.
> 
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> 

I'm creating a new call site conversion series, to replace the 
"put_user_pages(): miscellaneous call sites" series. This uses
vaddr_pin_pages*() where appropriate. So it's based on your series here.

btw, while doing that, I noticed one more typo while re-reading some of the comments. 
Thought you probably want to collect them all for the next spin. Below...

> ---
> Changes from list:
> 	Change to vaddr_put_pages_dirty_lock
> 	Change to vaddr_unpin_pages_dirty_lock
> 
>  include/linux/mm.h |  5 ++++
>  mm/gup.c           | 59 ++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 64 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 657c947bda49..90c5802866df 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1603,6 +1603,11 @@ int account_locked_vm(struct mm_struct *mm, unsigned long pages, bool inc);
>  int __account_locked_vm(struct mm_struct *mm, unsigned long pages, bool inc,
>  			struct task_struct *task, bool bypass_rlim);
>  
> +long vaddr_pin_pages(unsigned long addr, unsigned long nr_pages,
> +		     unsigned int gup_flags, struct page **pages,
> +		     struct vaddr_pin *vaddr_pin);
> +void vaddr_unpin_pages_dirty_lock(struct page **pages, unsigned long nr_pages,
> +				  struct vaddr_pin *vaddr_pin, bool make_dirty);
>  bool mapping_inode_has_layout(struct vaddr_pin *vaddr_pin, struct page *page);
>  
>  /* Container for pinned pfns / pages */
> diff --git a/mm/gup.c b/mm/gup.c
> index eeaa0ddd08a6..6d23f70d7847 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -2536,3 +2536,62 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>  	return ret;
>  }
>  EXPORT_SYMBOL_GPL(get_user_pages_fast);
> +
> +/**
> + * vaddr_pin_pages pin pages by virtual address and return the pages to the
> + * user.
> + *
> + * @addr, start address
> + * @nr_pages, number of pages to pin
> + * @gup_flags, flags to use for the pin
> + * @pages, array of pages returned
> + * @vaddr_pin, initalized meta information this pin is to be associated

Typo:
                  initialized


thanks,
-- 
John Hubbard
NVIDIA


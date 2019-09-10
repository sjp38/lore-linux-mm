Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD849C49ED9
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 07:10:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82299206A5
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 07:10:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82299206A5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 314866B0007; Tue, 10 Sep 2019 03:10:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C4E96B0008; Tue, 10 Sep 2019 03:10:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B3B86B000A; Tue, 10 Sep 2019 03:10:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0018.hostedemail.com [216.40.44.18])
	by kanga.kvack.org (Postfix) with ESMTP id E81E56B0007
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 03:10:33 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 894B3824376B
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 07:10:33 +0000 (UTC)
X-FDA: 75918137946.11.sofa16_3f0af8d32b04d
X-HE-Tag: sofa16_3f0af8d32b04d
X-Filterd-Recvd-Size: 2625
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 07:10:33 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 523C0AFF5;
	Tue, 10 Sep 2019 07:10:31 +0000 (UTC)
Date: Tue, 10 Sep 2019 09:10:30 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-rdma@vger.kernel.org, Jason Gunthorpe <jgg@mellanox.com>,
	Bernard Metzler <bmt@zurich.ibm.com>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: add dummy can_do_mlock() helper
Message-ID: <20190910071030.GG2063@dhcp22.suse.cz>
References: <20190909204201.931830-1-arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190909204201.931830-1-arnd@arndb.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 09-09-19 22:41:40, Arnd Bergmann wrote:
> On kernels without CONFIG_MMU, we get a link error for the siw
> driver:
> 
> drivers/infiniband/sw/siw/siw_mem.o: In function `siw_umem_get':
> siw_mem.c:(.text+0x4c8): undefined reference to `can_do_mlock'
> 
> This is probably not the only driver that needs the function
> and could otherwise build correctly without CONFIG_MMU, so
> add a dummy variant that always returns false.
> 
> Fixes: 2251334dcac9 ("rdma/siw: application buffer management")
> Suggested-by: Jason Gunthorpe <jgg@mellanox.com>
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Makes sense
Acked-by: Michal Hocko <mhocko@suse.com>

but IB on nonMMU? Whut? Is there any HW that actually supports this?
Just wondering...

> ---
>  include/linux/mm.h | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 66f296181bcc..cc292273e6ba 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1424,7 +1424,11 @@ extern void pagefault_out_of_memory(void);
>  
>  extern void show_free_areas(unsigned int flags, nodemask_t *nodemask);
>  
> +#ifdef CONFIG_MMU
>  extern bool can_do_mlock(void);
> +#else
> +static inline bool can_do_mlock(void) { return false; }
> +#endif
>  extern int user_shm_lock(size_t, struct user_struct *);
>  extern void user_shm_unlock(size_t, struct user_struct *);
>  
> -- 
> 2.20.0
> 

-- 
Michal Hocko
SUSE Labs


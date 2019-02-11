Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 028A9C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:39:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6F0B2084D
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:39:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="lEHdGLTD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6F0B2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 567FC8E0159; Mon, 11 Feb 2019 15:39:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 518708E0155; Mon, 11 Feb 2019 15:39:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BA138E0159; Mon, 11 Feb 2019 15:39:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id EB6568E0155
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:39:18 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id q21so196159pfi.17
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:39:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=P7ipRFd0lGsbjldrU5cPVYjS4TXNP1GlOAkJ0yUCCXI=;
        b=la+PSQ5+2DmVxVdLyWdf+kSgBlOrPAICki/5JLwB8+IOMwhTAHl3qso9QeLVngja4Y
         xHTZNoP9YPKYwqhfMaaBb4OzQ+yp4tV6zBbDWeDvQaZihcIKTOpTIpuHaoqbxW/FehjO
         jaYQAo4LhK96CR+wsXOdSZkqbQdKhylAsJqdvzJr5TuNfjnG2zXS3vDzSchNH7dgpmuU
         cdRTtDgxFwqKxJ04wY7wQlIaPKR9OuJx+ctPS/F4IvDbLy41W4zlkelMA0ltXFzM+LM/
         KryzQRY9Y3v5nsmkxF+8o18HTanzP3JJI0jq6p7bJvxhmKnk6Ih7PLDZwwpqtCUUZja6
         SzYg==
X-Gm-Message-State: AHQUAuZGK/H6RB0mQws6NThPOsQ9DWHreKQvKF0jyEvKOIHUVQmvBO8q
	E4T6hwzwz860vKfcA9p0+0Xv6JGd9kRKJPec8QCOZ2alJHjlvhj2jw+uJkTs+SJlbQtttO3aC0Q
	gmrwaFJ0/dBcLbnKmZFdaFnyy2DIa028qkrW/YiYa2C6hXFpsEVxJP14PH9JtMoh4hIWG9nIQqF
	JK2ngOrch2AjWPPYtpwXi3dkqUhukFPCySKZob2w0+wCNVquyH2/YM8/w9EtOeUnKh9jrkYiIPy
	Cq8ZwbmCVaDZy4Obcu4+aMTrdKNCY4pYmnUg3alYL5CdIzt8zAToYVvAh8AINYXf8OMK0KbRqW/
	MB0U57t+N9MjI8pq9BgzXFpalYR4j/pgpl6ab9w2wKGDEjO2KLP6W/9wfCmhSrukgu4VvTlN9d3
	n
X-Received: by 2002:aa7:8a17:: with SMTP id m23mr104645pfa.258.1549917558590;
        Mon, 11 Feb 2019 12:39:18 -0800 (PST)
X-Received: by 2002:aa7:8a17:: with SMTP id m23mr104592pfa.258.1549917557900;
        Mon, 11 Feb 2019 12:39:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549917557; cv=none;
        d=google.com; s=arc-20160816;
        b=U2Y8LN+OYidRAX49aVlmtjOIAYSU9xmQwBAWnJJhRVbhmFzJGhh/Pca65u4G6+E1CH
         Jg1HasH1zpFGSWGC+PTK6+J4l2cU8hXGQpDLz74S5rC3rWV18Kh+b9TavC7Sd/p4so2b
         KfknnTkkYZLMva+ZrEu49VoKy0f9c7HiT8kFL71wtNh5wzvp5mRA42v9DYyp4W199Eeo
         HdoU902XoNj0KO8R+P5RQXXlVU4iNKFQPZ1TZVCF8N/pw2R+D8pwet5Cczrl4ot0x4ng
         BwnW2tv1TwPJ8zSIwdyZluxOAyPBDsN9/9nPiHiTYbBVloP7/Ypy2FSKRB4Sy4MhNgCv
         pu7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=P7ipRFd0lGsbjldrU5cPVYjS4TXNP1GlOAkJ0yUCCXI=;
        b=TB6g06cKHvwLuTbYTNECb5xs13TBosUhEUl3xjoC5LY+V7bS9/2jblUVK4fTqXrJG+
         KImiA8sp3T+hRg8NVbxknBRM8pTjxRnOCY1RbnQyg8MTQCC+zx0EVD3m2wTLWi3JBZ1f
         B++fNkqbxmOW3kgOZZJZjZySZv61B2U0tsRQK8SsSC7YxieASREeXaB9uHj+HaLaTQqO
         J1K1LdLFLSrJY4KOPj2rRch1cDqMuDZeMqGjmpF1apYFtd9CLhI9a3u4Tw/w6D3TYq3s
         ZD0bnr5aErfc8cdl/tZfpcvVV3YyonWdKyluzun3p/+FcuQgtV31YUiQfEAHZGkAiPrn
         vIUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=lEHdGLTD;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p18sor15525700pgl.33.2019.02.11.12.39.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 12:39:17 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=lEHdGLTD;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=P7ipRFd0lGsbjldrU5cPVYjS4TXNP1GlOAkJ0yUCCXI=;
        b=lEHdGLTDe+z9XOLq92061yRszuQ30L0Ah2rmiBbRpewl+TcyLhd4uxI4utvOvqyaI2
         aj7uUuX092yr34YJFyYkt43rtb2Dkfumt2dbyWXGRWWzWz+mQH0n4KTPptuX0vmorWcU
         1W/+eazIscUyvxqV3K5ydoWP/wMD9KxZf9OYLLotNpA6ZOOGTYWv10ulE12tdrSoJjen
         a+l3YkwfqqnVqdLyeRlfhC2S4LulZqlNGf3+NZZS6ipLnh30ZGDMnZJfMHV+zx8QMtqX
         yAp75P/0zxF3T+6bl4zNzfa24iMzHvsrXSC5noAUxB++IktCPa99pDvyTnh8U3xFfhyM
         eZ6Q==
X-Google-Smtp-Source: AHgI3IbMSgV+Og1cgwCH3tEJ/kPJXOw9ltVSJm+RBFJMVVHZk30d9/NcXwyU987scjvfQpHKM+tRtw==
X-Received: by 2002:a63:eb49:: with SMTP id b9mr115173pgk.196.1549917557390;
        Mon, 11 Feb 2019 12:39:17 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id b13sm22468326pfj.66.2019.02.11.12.39.16
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 12:39:16 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gtIMG-0000kK-7Q; Mon, 11 Feb 2019 13:39:16 -0700
Date: Mon, 11 Feb 2019 13:39:16 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: ira.weiny@intel.com
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Daniel Borkmann <daniel@iogearbox.net>,
	Davidlohr Bueso <dave@stgolabs.net>, netdev@vger.kernel.org,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 2/3] mm/gup: Introduce get_user_pages_fast_longterm()
Message-ID: <20190211203916.GA2771@ziepe.ca>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190211201643.7599-3-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211201643.7599-3-ira.weiny@intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 12:16:42PM -0800, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> Users of get_user_pages_fast are not protected against mapping
> pages within FS DAX.  Introduce a call which protects them.
> 
> We do this by checking for DEVMAP pages during the fast walk and
> falling back to the longterm gup call to check for FS DAX if needed.
> 
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
>  include/linux/mm.h |   8 ++++
>  mm/gup.c           | 102 +++++++++++++++++++++++++++++++++++----------
>  2 files changed, 88 insertions(+), 22 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 80bb6408fe73..8f831c823630 100644
> +++ b/include/linux/mm.h
> @@ -1540,6 +1540,8 @@ long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
>  long get_user_pages_longterm(unsigned long start, unsigned long nr_pages,
>  			    unsigned int gup_flags, struct page **pages,
>  			    struct vm_area_struct **vmas);
> +int get_user_pages_fast_longterm(unsigned long start, int nr_pages, bool write,
> +				 struct page **pages);
>  #else
>  static inline long get_user_pages_longterm(unsigned long start,
>  		unsigned long nr_pages, unsigned int gup_flags,
> @@ -1547,6 +1549,11 @@ static inline long get_user_pages_longterm(unsigned long start,
>  {
>  	return get_user_pages(start, nr_pages, gup_flags, pages, vmas);
>  }
> +static inline int get_user_pages_fast_longterm(unsigned long start, int nr_pages,
> +					       bool write, struct page **pages)
> +{
> +	return get_user_pages_fast(start, nr_pages, write, pages);
> +}
>  #endif /* CONFIG_FS_DAX */
>  
>  int get_user_pages_fast(unsigned long start, int nr_pages, int write,
> @@ -2615,6 +2622,7 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
>  #define FOLL_REMOTE	0x2000	/* we are working on non-current tsk/mm */
>  #define FOLL_COW	0x4000	/* internal GUP flag */
>  #define FOLL_ANON	0x8000	/* don't do file mappings */
> +#define FOLL_LONGTERM	0x10000	/* mapping is intended for a long term pin */

If we are adding a new flag, maybe we should get rid of the 'longterm'
entry points and just rely on the callers to pass the flag?

Jason


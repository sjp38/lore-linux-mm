Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 35B44900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 17:13:59 -0400 (EDT)
Received: by pdbnf5 with SMTP id nf5so38601612pdb.2
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 14:13:58 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id h16si7555249pde.217.2015.06.04.14.13.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jun 2015 14:13:58 -0700 (PDT)
Received: by payr10 with SMTP id r10so36969887pay.1
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 14:13:58 -0700 (PDT)
Date: Fri, 5 Jun 2015 06:13:51 +0900
From: Tejun Heo <tj@kernel.org>
Subject: Re: writeback: implement memcg wb_domain
Message-ID: <20150604211351.GU20091@mtj.duckdns.org>
References: <20150604105738.GA7070@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150604105738.GA7070@mwanda>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-mm@kvack.org

On Thu, Jun 04, 2015 at 01:57:38PM +0300, Dan Carpenter wrote:
> Hello Tejun Heo,
> 
> The patch 841710aa6e4a: "writeback: implement memcg wb_domain" from
> May 22, 2015, leads to the following static checker warning:
> 
> 	mm/backing-dev.c:558 cgwb_create()
> 	warn: missing error code here? 'wb_congested_get_create()' failed. 'ret' = '0'
> 
> mm/backing-dev.c
>    548          ret = percpu_ref_init(&wb->refcnt, cgwb_release, 0, gfp);
>    549          if (ret)
>    550                  goto err_wb_exit;
>    551  
>    552          ret = fprop_local_init_percpu(&wb->memcg_completions, gfp);
>    553          if (ret)
>    554                  goto err_ref_exit;
>    555  
>    556          wb->congested = wb_congested_get_create(bdi, blkcg_css->id, gfp);
>    557          if (!wb->congested)
>    558                  goto err_fprop_exit;
>                         ^^^^^^^^^^^^^^^^^^^
> Did you want to set ret = -ENOMEM here?

Yes, definitely.  Thank you very much for spotting it.  Will send a
fix patch soon.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

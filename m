Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id A2F8A900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 06:57:51 -0400 (EDT)
Received: by obbqz1 with SMTP id qz1so11278540obb.3
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 03:57:51 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id w186si1373105oif.127.2015.06.04.03.57.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jun 2015 03:57:50 -0700 (PDT)
Date: Thu, 4 Jun 2015 13:57:38 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: writeback: implement memcg wb_domain
Message-ID: <20150604105738.GA7070@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org
Cc: linux-mm@kvack.org

Hello Tejun Heo,

The patch 841710aa6e4a: "writeback: implement memcg wb_domain" from
May 22, 2015, leads to the following static checker warning:

	mm/backing-dev.c:558 cgwb_create()
	warn: missing error code here? 'wb_congested_get_create()' failed. 'ret' = '0'

mm/backing-dev.c
   548          ret = percpu_ref_init(&wb->refcnt, cgwb_release, 0, gfp);
   549          if (ret)
   550                  goto err_wb_exit;
   551  
   552          ret = fprop_local_init_percpu(&wb->memcg_completions, gfp);
   553          if (ret)
   554                  goto err_ref_exit;
   555  
   556          wb->congested = wb_congested_get_create(bdi, blkcg_css->id, gfp);
   557          if (!wb->congested)
   558                  goto err_fprop_exit;
                        ^^^^^^^^^^^^^^^^^^^
Did you want to set ret = -ENOMEM here?

   559  

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id E06676B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 11:05:00 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id wp4so32155997obc.0
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 08:05:00 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id u75si4704545oif.85.2015.03.02.08.04.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 08:05:00 -0800 (PST)
Received: from acsinet22.oracle.com (acsinet22.oracle.com [141.146.126.238])
	by aserp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t22G4wZr030337
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 2 Mar 2015 16:04:59 GMT
Received: from aserz7021.oracle.com (aserz7021.oracle.com [141.146.126.230])
	by acsinet22.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id t22G4wB2007171
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Mon, 2 Mar 2015 16:04:58 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
	by aserz7021.oracle.com (8.14.4+Sun/8.14.4) with ESMTP id t22G4wLG024567
	for <linux-mm@kvack.org>; Mon, 2 Mar 2015 16:04:58 GMT
Date: Mon, 2 Mar 2015 19:04:47 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: mm: cma: debugfs interface
Message-ID: <20150302160447.GA6329@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sasha.levin@oracle.com
Cc: linux-mm@kvack.org

Hello Sasha Levin,

The patch 7af80f2392eb: "mm: cma: debugfs interface" from Feb 26,
2015, leads to the following static checker warning:

	mm/cma_debug.c:154 cma_debugfs_add_one()
	warn: passing casted pointer 'cma->bitmap' to 'debugfs_create_u32_array()' 64 vs 32.

mm/cma_debug.c
   130  static void cma_debugfs_add_one(struct cma *cma, int idx)
   131  {
   132          struct dentry *tmp;
   133          char name[16];
   134          int u32s;
   135  
   136          sprintf(name, "cma-%d", idx);
   137  
   138          tmp = debugfs_create_dir(name, cma_debugfs_root);
   139  
   140          debugfs_create_file("alloc", S_IWUSR, cma_debugfs_root, cma,
   141                                  &cma_alloc_fops);
   142  
   143          debugfs_create_file("free", S_IWUSR, cma_debugfs_root, cma,
   144                                  &cma_free_fops);
   145  
   146          debugfs_create_file("base_pfn", S_IRUGO, tmp,
   147                                  &cma->base_pfn, &cma_debugfs_fops);
   148          debugfs_create_file("count", S_IRUGO, tmp,
   149                                  &cma->count, &cma_debugfs_fops);
   150          debugfs_create_file("order_per_bit", S_IRUGO, tmp,
   151                                  &cma->order_per_bit, &cma_debugfs_fops);
   152  
   153          u32s = DIV_ROUND_UP(cma_bitmap_maxno(cma), BITS_PER_BYTE * sizeof(u32));
   154          debugfs_create_u32_array("bitmap", S_IRUGO, tmp, (u32*)cma->bitmap, u32s);
                                                                       ^^^^^^^^^^^
This won't work on big endian systems.  If ->bitmap really only uses 32
bits then we could declare it as u32 instead of long.

   155  }

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

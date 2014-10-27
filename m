Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id B4AD9900021
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 16:18:17 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id ft15so4315859pdb.7
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 13:18:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a13si11287446pat.149.2014.10.27.13.18.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Oct 2014 13:18:16 -0700 (PDT)
Date: Mon, 27 Oct 2014 13:18:16 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [mmotm:master 59/223] fs/ocfs2/aops.c:654:14: warning:
 comparison of distinct pointer types lacks a cast
Message-Id: <20141027131816.502d8e2506843e8951f5933a@linux-foundation.org>
In-Reply-To: <5449f4e7.+mDOGzw+O8rZdQFO%fengguang.wu@intel.com>
References: <5449f4e7.+mDOGzw+O8rZdQFO%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, WeiWei Wang <wangww631@huawei.com>, Linux Memory Management List <linux-mm@kvack.org>, kbuild-all@01.org

On Fri, 24 Oct 2014 14:42:47 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:

> tree:   git://git.cmpxchg.org/linux-mmotm.git master
> head:   bb578c9c690d8a5525dafc52d442af18aee45280
> commit: 5a9558722362888f158e60e5126296c867eb4a8f [59/223] ocfs2-add-and-remove-inode-in-orphan-dir-in-ocfs2_direct_io-fix
> config: sh-allyesconfig (attached as .config)
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout 5a9558722362888f158e60e5126296c867eb4a8f
>   # save the attached .config to linux build tree
>   make.cross ARCH=sh 
> 
> All warnings:
> 
>    fs/ocfs2/aops.c: In function 'ocfs2_direct_IO_write':
> >> fs/ocfs2/aops.c:654:14: warning: comparison of distinct pointer types lacks a cast [enabled by default]
> 
> vim +654 fs/ocfs2/aops.c
> 
>    638		struct ocfs2_super *osb = OCFS2_SB(inode->i_sb);
>    639		struct buffer_head *di_bh = NULL;
>    640		size_t count = iter->count;
>    641		journal_t *journal = osb->journal->j_journal;
>    642		u32 p_cpos = 0;
>    643		u32 v_cpos = ocfs2_clusters_for_bytes(osb->sb, offset);
>    644		u32 zero_len;
>    645		int cluster_align;
>    646		loff_t final_size = offset + count;
>    647		int append_write = offset >= i_size_read(inode) ? 1 : 0;
>    648		unsigned int num_clusters = 0;
>    649		unsigned int ext_flags = 0;
>    650	
>    651		{
>    652			loff_t o = offset;
>    653	
>  > 654			zero_len = do_div(o, 1 << osb->s_clustersize_bits);
>    655			cluster_align = !!zero_len;
>    656		}

hm, yes.

--- a/fs/ocfs2/aops.c~ocfs2-add-and-remove-inode-in-orphan-dir-in-ocfs2_direct_io-fix-fix
+++ a/fs/ocfs2/aops.c
@@ -649,7 +649,7 @@ static ssize_t ocfs2_direct_IO_write(str
 	unsigned int ext_flags = 0;
 
 	{
-		loff_t o = offset;
+		u64 o = offset;
 
 		zero_len = do_div(o, 1 << osb->s_clustersize_bits);
 		cluster_align = !!zero_len;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Received: from [192.168.8.55] ([192.168.8.55])
	(authenticated bits=0)
	by arcamail.arcapub.arca.com (8.12.8/8.12.8) with ESMTP id lAE43k7W025071
	for <linux-mm@kvack.org>; Wed, 14 Nov 2007 12:03:50 +0800
Message-ID: <473A7877.90703@arca.com.cn>
Date: Wed, 14 Nov 2007 12:24:23 +0800
From: "Jacky(GuangXiang Lee)" <gxli@arca.com.cn>
MIME-Version: 1.0
Subject: probably memory leak in sparse_index_init()? ---2.6.23/mm/sparse.c
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi,
As following,after allocing ,then go out at finding mem_section not
null.sure?


static int __meminit sparse_index_init(unsigned long section_nr, int nid)
{
static DEFINE_SPINLOCK(index_init_lock);
unsigned long root = SECTION_NR_TO_ROOT(section_nr);
struct mem_section *section;
int ret = 0;

if (mem_section[root])
return -EEXIST;

section = sparse_index_alloc(nid);
/*
* This lock keeps two different sections from
* reallocating for the same index
*/
spin_lock(&index_init_lock);

if (mem_section[root]) {
ret = -EEXIST;
goto out;
}

mem_section[root] = section;
out:
spin_unlock(&index_init_lock);
return ret;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

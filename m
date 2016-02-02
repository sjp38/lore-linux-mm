Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8871E6B0009
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 21:20:48 -0500 (EST)
Received: by mail-ig0-f180.google.com with SMTP id t15so50338861igr.0
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 18:20:48 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id w62si1120033iof.21.2016.02.01.18.20.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Feb 2016 18:20:47 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: kernel BUG at mm/hugetlb.c:1218!
Date: Tue, 2 Feb 2016 02:19:14 +0000
Message-ID: <20160202021913.GA12609@hori1.linux.bs1.fc.nec.co.jp>
References: <56B00529.6080807@oracle.com>
In-Reply-To: <56B00529.6080807@oracle.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <B2F31B753B28C64395E9477FC4BBF45C@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>

On Mon, Feb 01, 2016 at 05:23:53PM -0800, Mike Kravetz wrote:
> I just noticed that recent mmotm and linux-next kernels will not boot if
> you attempt to preallocate 1G huge pages at boot time (on x86).  To
> preallocate, simply add "hugepagesz=3D1G hugepages=3D1" to kernel command
> line.  I have not yet started to debug.  However, based on the
> "BUG_ON(page_mapcount(page));" I am guessing it is related to recent
> mapcount/refcount changes.

Hi Mike,

Thank you for reporting.
Comparing prep_compound_page() and prep_compound_gigantic_page(),
prep_compound_gigantic_page() doesn't initialize compound_mapcount,
so simply doing like below should fix this (I briefly confirmed it.)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 8afd5fc09f70..9b931134e9df 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1286,6 +1286,7 @@ static void prep_compound_gigantic_page(struct page *=
page, unsigned int order)
 		set_page_count(p, 0);
 		set_compound_head(p, page);
 	}
+	atomic_set(compound_mapcount_ptr(page), -1);
 }
=20
 /*


BTW, BUG_ON() in free_huge_page() can be replaced with improved version
of VM_BUG_ON_PAGE() to help our debugging. Could you work on it, too?

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

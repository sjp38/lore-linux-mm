Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 8AAD4900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 13:09:04 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so34915140pdb.0
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 10:09:04 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id pr7si6701872pdb.236.2015.06.04.10.09.03
        for <linux-mm@kvack.org>;
        Thu, 04 Jun 2015 10:09:03 -0700 (PDT)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [RFC PATCH 10/12] mm: add the buddy system interface
Date: Thu, 4 Jun 2015 17:09:03 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F32A8D5C7@ORSMSX114.amr.corp.intel.com>
References: <55704A7E.5030507@huawei.com> <55704CC4.8040707@huawei.com>
In-Reply-To: <55704CC4.8040707@huawei.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, "nao.horiguchi@gmail.com" <nao.horiguchi@gmail.com>, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

+#ifdef CONFIG_MEMORY_MIRROR
+	if (change_to_mirror(gfp_mask, ac.high_zoneidx))
+		ac.migratetype =3D MIGRATE_MIRROR;
+#endif

We may have to be smarter than this here. I'd like to encourage the
enterprise Linux distributions to set CONFIG_MEMORY_MIRROR=3Dy
But the reality is that most systems will not configure any mirrored
memory - so we don't want the common code path for memory
allocation to call functions that set the migrate type, try to allocate
and then fall back to a non-mirror when that may be a complete waste
of time.

Maybe a global "got_mirror" that is true if we have some mirrored
memory.  Then code is

	if (got_mirror && change_to_mirror(...))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

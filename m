Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 6D8396B0044
	for <linux-mm@kvack.org>; Wed,  5 Dec 2012 17:13:45 -0500 (EST)
From: "Luck, Tony" <tony.luck@intel.com>
Subject: RE: [PATCH 1/3] HWPOISON, hugetlbfs: fix warning on freeing
 hwpoisoned hugepage
Date: Wed, 5 Dec 2012 22:13:42 +0000
Message-ID: <3908561D78D1C84285E8C5FCA982C28F1C963B5E@ORSMSX108.amr.corp.intel.com>
References: <1354744058-26373-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1354744058-26373-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1354744058-26373-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>
Cc: "Wu, Fengguang" <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> This patch fixes the warning from __list_del_entry() which is triggered
> when a process tries to do free_huge_page() for a hwpoisoned hugepage.

Ultimately it would be nice to avoid poisoning huge pages. Generally we kno=
w the
location of the poison to a cache line granularity (but sometimes only to a=
 4K
granularity) ... and it is rather inefficient to take an entire 2M page out=
 of service.
With 1G pages things would be even worse!!

It also makes life harder for applications that would like to catch the SIG=
BUS
and try to take their own recovery actions. Losing more data than they real=
ly
need to will make it less likely that they can do something to work around =
the
loss.

Has anyone looked at how hard it might be to have the code in memory-failur=
e.c
break up a huge page and only poison the 4K that needs to be taken out of s=
ervice?

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

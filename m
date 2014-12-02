Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id C26096B0069
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 09:57:01 -0500 (EST)
Received: by mail-wi0-f173.google.com with SMTP id r20so28321851wiv.6
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 06:57:01 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id yv4si35362764wjc.120.2014.12.02.06.56.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Dec 2014 06:56:59 -0800 (PST)
Message-ID: <547DD327.6070708@redhat.com>
Date: Tue, 02 Dec 2014 09:56:39 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/4] mm: refactor do_wp_page, extract the page copy
 flow
References: <1417467491-20071-1-git-send-email-raindel@mellanox.com> <1417467491-20071-4-git-send-email-raindel@mellanox.com> <547D29A3.7090108@redhat.com> <b33f68fb290142379f1189efbd8ea557@AM3PR05MB0935.eurprd05.prod.outlook.com>
In-Reply-To: <b33f68fb290142379f1189efbd8ea557@AM3PR05MB0935.eurprd05.prod.outlook.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shachar Raindel <raindel@mellanox.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "kirill.shutemov@linux.intel.com" <kirill.shutemov@linux.intel.com>, "mgorman@suse.de" <mgorman@suse.de>, "ak@linux.intel.com" <ak@linux.intel.com>, "matthew.r.wilcox@intel.com" <matthew.r.wilcox@intel.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "n-horiguchi@ah.jp.nec.com" <n-horiguchi@ah.jp.nec.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, Haggai Eran <haggaie@mellanox.com>, "aarcange@redhat.com" <aarcange@redhat.com>, "pfeiner@google.com" <pfeiner@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Sagi Grimberg <sagig@mellanox.com>, "walken@google.com" <walken@google.com>, Jerome Glisse <j.glisse@gmail.com>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 12/02/2014 04:09 AM, Shachar Raindel wrote:

>> I believe the mmu_notifier_invalidate_range_start & _end 
>> functions can be moved inside the pte_same(*page_table,
>> orig_pte) branch. There is no reason to call those functions if
>> we do not modify the page table entry.
>> 
> 
> There is a critical reason for this - moving the MMU notifiers
> there will make them unsleepable. This will prevent hardware
> devices that keep secondary PTEs from waiting for an interrupt to
> signal that the invalidation was completed. This is required for
> example by the ODP patch set 
> (http://www.spinics.net/lists/linux-rdma/msg22044.html ) and by the
> HMM patch set
> (http://comments.gmane.org/gmane.linux.kernel.mm/116584 ).

Ahhhh, that explains!

Acked-by: Rik van Riel <riel@redhat.com>

- -- 
All rights reversed
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAEBAgAGBQJUfdMnAAoJEM553pKExN6D6HQH/jYio5UBhlPhjp9XjWxwrDHy
7Pcf9nATYQhSN5IuxWp265yHMbFu9CwJefW2DLZLXbynImiy8rkl0HkaaDXEZnM4
ZizjCcxjgNVxD+F+EAsi/bj6kCtxNfmM0YxLCNHjOp835JQzQTbx94Joy1B10ba+
42sTbGBArBVVuDOfHpiUMCj8HFiRT2BNwpfu44eDLAJQiTZIYU5OlXmWnSJQXDDF
c648arGq75fyA8RHRZ/cTf0pztT+Gx5q/2LAxy+MkhiZjX9kXc1e98gWTOO70Qj+
IwP4YAfgScts+uqL2Q+EUVo0nBYAT1amyZft6j3aLQRrDcFhCkITk2VW0CdZHdE=
=IA5v
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id E3C926B0069
	for <linux-mm@kvack.org>; Wed,  1 Oct 2014 13:17:30 -0400 (EDT)
Received: by mail-qc0-f173.google.com with SMTP id x13so693351qcv.4
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 10:17:30 -0700 (PDT)
Received: from omr2.cc.vt.edu (omr2.cc.ipv6.vt.edu. [2001:468:c80:2105:0:24d:7091:8b9c])
        by mx.google.com with ESMTPS id m6si2669793qaa.127.2014.10.01.10.17.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Oct 2014 10:17:30 -0700 (PDT)
Subject: Re: [PATCH v11 00/21] Add support for NV-DIMMs to ext4
In-Reply-To: Your message of "Wed, 01 Oct 2014 11:45:47 -0400."
             <x49r3yrn68k.fsf@segfault.boston.devel.redhat.com>
From: Valdis.Kletnieks@vt.edu
References: <1411677218-29146-1-git-send-email-matthew.r.wilcox@intel.com> <15705.1412070301@turing-police.cc.vt.edu> <20140930144854.GA5098@wil.cx> <123795.1412088827@turing-police.cc.vt.edu> <20140930160841.GB5098@wil.cx> <15704.1412109476@turing-police.cc.vt.edu> <A8F88370-512D-45D0-8414-C478D64E46E5@dilger.ca> <62749.1412113956@turing-police.cc.vt.edu>
            <x49r3yrn68k.fsf@segfault.boston.devel.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1412183841_2347P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Wed, 01 Oct 2014 13:17:21 -0400
Message-ID: <9487.1412183841@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Andreas Dilger <adilger@dilger.ca>, Matthew Wilcox <willy@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

--==_Exmh_1412183841_2347P
Content-Type: text/plain; charset=us-ascii

On Wed, 01 Oct 2014 11:45:47 -0400, Jeff Moyer said:

> This sounds an awful lot like posix_fadvise' POSIX_FADV_NOREUSE flag.

Gaah. Premature click.  man posix_fadvise says this:

       In kernels before 2.6.18, POSIX_FADV_NOREUSE had the same semantics  as
       POSIX_FADV_WILLNEED.   This  was  probably  a bug; since kernel 2.6.18,
       this flag is a no-op.

and mm/fadvise.c says this:
        switch (advice) {
        case POSIX_FADV_NORMAL:
                f.file->f_ra.ra_pages = bdi->ra_pages;
                spin_lock(&f.file->f_lock);
                f.file->f_mode &= ~FMODE_RANDOM;
                spin_unlock(&f.file->f_lock);
...
	                 */
                force_page_cache_readahead(mapping, f.file, start_index,
                                           nrpages);
                break;
        case POSIX_FADV_NOREUSE:
                break;
        case POSIX_FADV_DONTNEED:
                if (!bdi_write_congested(mapping->backing_dev_info))
                        __filemap_fdatawrite_range(mapping, offset, endbyte,
                                                   WB_SYNC_NONE);

                /* First and last FULL page! */

So... not much interface there, actually.  One wonders if removing the 'break;'
and allowing a fall-through would actually be an improvement....

--==_Exmh_1412183841_2347P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVCw3IQdmEQWDXROgAQIZaw/+NXbC9mR/tCaZSx+zdxrhOArKos2TcUu3
jqJTFEeK7794NGIlYb/OaELCoSyQcYNoffo76/Si4d2Pxf5limmQJOmaNiuNzdse
ZpaxBxp44yg+urLP0KY/flSdxd7gCq47I1kwCxwdw6Sbx2YJF1nX51m1PTjVw3dy
4xijAyMVgMpCahFlbC2Ita5HO0+++eqDEYq7qLvztPWS9J+cq0gMGZKWWaiuvDq0
tTxzh3pi+G/aCppZnrIEM+tnAaEga+wyluZZ4TOQz4IbHBIEIt988PA+SLB8unTU
1gUWrla3upVenlAv8kWhSdZTRVkQcnlgY+HE1UY1DXfeBCTGIYXueF9d81sQhuvf
fCmOftbJna3eNf1QlMc6oSm4XMmczQ1SysFi2B0yqe6DoxGoQuoTV/QbPAIKmO6s
u/DuRxzsHuZOhGPob32cMcMT0ALXUvh5OfPFHs5wbd1N9qwx2im4lYPRh25BIqR/
ZNuGzXJ/tHDC5s55drYKtpQNgE1yFDu/hSlAEAtV4IqYXDdfRwWhQxFJKFrpe6E9
D/cTIb25nXWISQ8io5EJahNyeboiPac5X82OMs7uYHDTChIWtoce3+Q1U97Gz2/C
+S3rh2MroSF6x+zQ4xbhBwjhQ8x7BtniUdGGsIObTArZJZVS7bY636ksev2j/FcY
0d/neydDOU4=
=BMzR
-----END PGP SIGNATURE-----

--==_Exmh_1412183841_2347P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

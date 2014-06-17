Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f177.google.com (mail-qc0-f177.google.com [209.85.216.177])
	by kanga.kvack.org (Postfix) with ESMTP id D69486B0031
	for <linux-mm@kvack.org>; Tue, 17 Jun 2014 10:09:13 -0400 (EDT)
Received: by mail-qc0-f177.google.com with SMTP id r5so6359822qcx.8
        for <linux-mm@kvack.org>; Tue, 17 Jun 2014 07:09:13 -0700 (PDT)
Received: from qmta05.emeryville.ca.mail.comcast.net (qmta05.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:48])
        by mx.google.com with ESMTP id h69si10202583qgd.93.2014.06.17.07.09.12
        for <linux-mm@kvack.org>;
        Tue, 17 Jun 2014 07:09:13 -0700 (PDT)
Date: Tue, 17 Jun 2014 09:09:09 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: mm: NULL ptr deref in remove_migration_pte
In-Reply-To: <539F5BC5.3010501@oracle.com>
Message-ID: <alpine.DEB.2.11.1406170907540.12946@gentwo.org>
References: <534E9ACA.2090008@oracle.com> <5367B365.1070709@oracle.com> <537FE9F3.40508@oracle.com> <alpine.LSU.2.11.1405261255530.3649@eggly.anvils> <538498A1.7010305@oracle.com> <alpine.LSU.2.11.1406092104330.12382@eggly.anvils>
 <539F5BC5.3010501@oracle.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Mel Gorman <mgorman@suse.de>, Bob Liu <bob.liu@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Dave Jones <davej@redhat.com>

On Mon, 16 Jun 2014, Sasha Levin wrote:

> It took some time to hit something here, but I think that the following
> is related:

This related thing looks like someone did a random memset. The SLUB
diagnostic show the object, redzone and padding were overwritten with
zeros.

> [  494.710068] =============================================================================
> [  494.710068] BUG page->ptl (Not tainted): Redzone overwritten
> [  494.710068] -----------------------------------------------------------------------------
> [  494.710068]
> [  494.710068] INFO: 0xffff8804e4730e58-0xffff8804e4730e5f. First byte 0x0 instead of 0xbb
> [  494.710068] INFO: Slab 0xffffea001391cc00 objects=40 used=40 fp=0x          (null) flags=0x56fffff80004080
> [  494.710068] INFO: Object 0xffff8804e4730e10 @offset=3600 fp=0x          (null)
> [  494.710068]
> [  494.710068] Bytes b4 ffff8804e4730e00: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  494.710068] Object ffff8804e4730e10: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  494.710068] Object ffff8804e4730e20: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  494.710068] Object ffff8804e4730e30: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  494.710068] Object ffff8804e4730e40: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
> [  494.710068] Object ffff8804e4730e50: 00 00 00 00 00 00 00 00                          ........
> [  494.710068] Redzone ffff8804e4730e58: 00 00 00 00 00 00 00 00                          ........
> [  494.710068] Padding ffff8804e4730f98: 00 00 00 00 00 00 00 00                          ........

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id C28966B0035
	for <linux-mm@kvack.org>; Thu,  4 Sep 2014 04:05:34 -0400 (EDT)
Received: by mail-we0-f175.google.com with SMTP id k48so9771907wev.34
        for <linux-mm@kvack.org>; Thu, 04 Sep 2014 01:05:32 -0700 (PDT)
Received: from ppsw-50.csi.cam.ac.uk (ppsw-50.csi.cam.ac.uk. [131.111.8.150])
        by mx.google.com with ESMTPS id q1si15115837wje.80.2014.09.04.01.05.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Sep 2014 01:05:30 -0700 (PDT)
Subject: Re: [PATCH] mm: clear __GFP_FS when PF_MEMALLOC_NOIO is set
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
From: Anton Altaparmakov <aia21@cam.ac.uk>
In-Reply-To: <20140903193058.2bc891a7.akpm@linux-foundation.org>
Date: Thu, 4 Sep 2014 09:05:23 +0100
Content-Transfer-Encoding: quoted-printable
Message-Id: <540555BE-7985-4468-BC03-45CDA7E2EB83@cam.ac.uk>
References: <1409723694-16047-1-git-send-email-junxiao.bi@oracle.com> <20140903161000.f383fa4c1a4086de054cb6a0@linux-foundation.org> <5407C989.50605@oracle.com> <20140903193058.2bc891a7.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Junxiao Bi <junxiao.bi@oracle.com>, david@fromorbit.com, xuejiufei@huawei.com, ming.lei@canonical.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On 4 Sep 2014, at 03:30, Andrew Morton <akpm@linux-foundation.org> =
wrote:
> __GFP_FS and __GFP_IO are (or were) for communicating to vmscan: don't
> enter the fs for writepage, don't write back swapcache.
>=20
> I guess those concepts have grown over time without a ton of thought
> going into it.  Yes, I suppose that if a filesystem's writepage is
> called (for example) it expects that it will be able to perform
> writeback and it won't check (or even be passed) the __GFP_IO setting.
>=20
> So I guess we could say that !__GFP_FS && GFP_IO is not implemented =
and
> shouldn't occur.
>=20
> That being said, it still seems quite bad to disable VFS cache
> shrinking for PF_MEMALLOC_NOIO allocation attempts.

I think what it really boils down to is that file systems cannot allow =
recursion into _that_ file system so if VFS/VM shrinking could skip over =
all inodes/dentries/pages that are associated with the superblock of the =
volume for which the allocation is being done then that would be just =
fine.

An alternative would be that the file systems would need to be passed in =
a flag that will tell them that it is not safe to take locks and then =
file systems that need to take a lock could return with -EDEADLOCK and =
the VM can then skip over those entries and reclaim others.  Though I =
think it would be more efficient for the VFS/VM to simply not call into =
the file system that is doing the allocation as above...

Best regards,

	Anton
--=20
Anton Altaparmakov <aia21 at cam.ac.uk> (replace at with @)
University of Cambridge Information Services, Roger Needham Building
7 JJ Thomson Avenue, Cambridge, CB3 0RB, UK

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

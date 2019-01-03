Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DF5AC43387
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 17:06:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AC0E2070D
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 17:06:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AC0E2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA0A68E008B; Thu,  3 Jan 2019 12:06:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E26DC8E0002; Thu,  3 Jan 2019 12:06:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF0DB8E008B; Thu,  3 Jan 2019 12:06:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9CCB58E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 12:06:12 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id y83so39917013qka.7
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 09:06:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=jnuEFmPGBVDL/DypPcoitmXnPeB2U0pG3leKGrb+N1U=;
        b=iTEl52u0FwMxXOI/iLDznorjH/og4izTOK/+XF/4+WJvc22zoiy3w5j2t+hlyIdov3
         6LVhqZj8xWR6EClB+Ol54YfK1PB07enweDya809wKZO6Pe0YJNMx8ZBFpfcDQJrtJq52
         /4kebKR1/90X2LGN8W0A7d2F5Ml8j8DhyZ4G2SSYSiYo0u0fGaKkDMB02rCT0FPli9mo
         /nrNT979/yzp6OIPjv+hqm21ktzZRdkshycj6iGyCAcD1O0Jtr0EV0i826ZYX7HrzxxC
         AES02z+dHE+wWUYf0dxYe2mpsS64OQEdBdq07dep7CARMeTk252H04HLB6rGy33GcdsZ
         30vg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukeHqyklexlMxHzr6czTRZDXURW5QcuxTLzuq5DSEZ3hVqvuszAK
	QFuIPyKE2s9ieg1w/qeRKVXPBmhIMALSECLCH9tplXdnFhKmBl6qjWVLwSUObl4A6v/RW6RBR53
	QlnjsQb3t/j3ZApC3/7iCjloGJGYKq1Ks/xxDxJE/UKAJLSAHBDZWcUGRoO3sF/DWbg==
X-Received: by 2002:a0c:c404:: with SMTP id r4mr21202473qvi.131.1546535172402;
        Thu, 03 Jan 2019 09:06:12 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5uWm5h0KJx7zypcwUNDLcijKyfzh++DhuQRfHlZ/dl+lbCT++0dbeoVh8XQb5ZvOrt3OJ0
X-Received: by 2002:a0c:c404:: with SMTP id r4mr21202407qvi.131.1546535171703;
        Thu, 03 Jan 2019 09:06:11 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546535171; cv=none;
        d=google.com; s=arc-20160816;
        b=wE79P6dqykXpLRPuPzDbc0himzk6Zhr/vvgkKH94jzEJhv2sv/VR5LNM0UJHpqD9O7
         5VlNMXFlypywplUGmhQ8NPIzoUf2WqbNjlnHp11WeqMax/3u0HqjZfvvBzSLBUKKzUob
         gqdMGtKBgt+6zoFFpeeBli5vXDl+fzGLBCikCy9nNhOJFuTCDwGfVsntdRNzqP07zs9Z
         DOLTB897KDTu2u/zTiiVwS6HTk/0kgSURD4qydLEfTZLLzzVdzcAkEikMf9iieqVPQpa
         NgVJ3WrB4KlbMn5j0ZheEA/uqfvsMTOj1Shep6NI/YFMuPxZh/0H1K19xiiOSlVwkfjs
         x4hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=jnuEFmPGBVDL/DypPcoitmXnPeB2U0pG3leKGrb+N1U=;
        b=IT8jnORIJDHkAmU7ibpS8Jzp92+SosbwEjqdFcq19/ftb5y0fjdfdi8FO91e73VPLV
         em9ptW8+gCV2B/BWhvfQ9qXYAZIkFsRXMQbWD2wy0t/F0tN1DT1Dk2AjoT8cek8SQ9sV
         yiPIBQj+BNuYPyClke2GdqmE+JSlbO0vDoZZo8n6LXB0lw/Y05G75D5WgxZenSLHck+Z
         RdH9haSbPBpuFY0GaVKYzHQ3JOGpkIL/7TIz8q6RQVkZYxg26UaZ+HQf4KQIp41qlozO
         N+kDg5wqJozx8x04LcpNUW/I56KDNcgvrMN4EYBPQyZ13SYRyFQcvy0o4+erW7aOrXli
         idcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s188si83683qkh.260.2019.01.03.09.06.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 09:06:11 -0800 (PST)
Received-SPF: pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 496BC8AE70;
	Thu,  3 Jan 2019 17:06:10 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 2510060C45;
	Thu,  3 Jan 2019 17:06:10 +0000 (UTC)
Received: from zmail17.collab.prod.int.phx2.redhat.com (zmail17.collab.prod.int.phx2.redhat.com [10.5.83.19])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id 95F1D3F600;
	Thu,  3 Jan 2019 17:06:09 +0000 (UTC)
Date: Thu, 3 Jan 2019 12:06:09 -0500 (EST)
From: Jan Stancek <jstancek@redhat.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, kirill shutemov <kirill.shutemov@linux.intel.com>, 
	Andrew Morton <akpm@linux-foundation.org>, ltp@lists.linux.it, 
	mhocko@kernel.org, Rachel Sibley <rasibley@redhat.com>, 
	hughd@google.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, 
	aneesh kumar <aneesh.kumar@linux.vnet.ibm.com>, dave@stgolabs.net, 
	prakash sangappa <prakash.sangappa@oracle.com>, 
	colin king <colin.king@canonical.com>
Message-ID: <495081357.93179893.1546535169172.JavaMail.zimbra@redhat.com>
In-Reply-To: <1808265696.93134171.1546519652798.JavaMail.zimbra@redhat.com>
References: <1323128903.93005102.1546461004635.JavaMail.zimbra@redhat.com> <6e608107-e071-90c0-bd73-4215325433c1@oracle.com> <dc056866-0e60-6ffa-54d5-5cafa1a4a53f@oracle.com> <1808265696.93134171.1546519652798.JavaMail.zimbra@redhat.com>
Subject: Re: [bug] problems with migration of huge pages with
 v4.20-10214-ge1ef035d272e
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Originating-IP: [10.43.17.9, 10.4.195.1]
Thread-Topic: problems with migration of huge pages with v4.20-10214-ge1ef035d272e
Thread-Index: x/KDbXSS9ZtifY8KCQZrHvya/x6QdqKmbuQ6
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Thu, 03 Jan 2019 17:06:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103170609.v1MOsHpxlBMUG0Yz7LHuHiu8GsCYsw3B49O1mzw60Ks@z>



----- Original Message -----
<snip>

> > That commit does cause BUGs for migration and page poisoning of anon hu=
ge
> > pages.  The patch was trying to take care of i_mmap_rwsem locking outsi=
de
> > try_to_unmap infrastructure.  This is because try_to_unmap will take th=
e
> > semaphore in read mode (for file mappings) and we really need it to be
> > taken in write mode.
> >=20
> > The patch below continues to take the semaphore outside try_to_unmap fo=
r
> > the file mapping case.  For anon mappings, the locking is done as a spe=
cial
> > case in try_to_unmap_one.  This is something I was trying to avoid as i=
t
> > it harder to follow/understand.  Any suggestions on how to restructure =
this
> > or make it more clear are welcome.
> >=20
> > Adding Andrew on Cc as he already sent the commit causing the BUGs
> > upstream.
> >=20
> > From: Mike Kravetz <mike.kravetz@oracle.com>
> >=20
> > hugetlbfs: fix migration and poisoning of anon huge pages
> >=20
> > Expanded use of i_mmap_rwsem for pmd sharing synchronization incorrectl=
y
> > used page_mapping() of anon huge pages to get to address_space
> > i_mmap_rwsem.  Since page_mapping() is NULL for pages of anon mappings,
> > an "unable to handle kernel NULL pointer" BUG would occur with stack
> > similar to:
> >=20
> > RIP: 0010:down_write+0x1b/0x40
> > Call Trace:
> >  migrate_pages+0x81f/0xb90
> >  __ia32_compat_sys_migrate_pages+0x190/0x190
> >  do_move_pages_to_node.isra.53.part.54+0x2a/0x50
> >  kernel_move_pages+0x566/0x7b0
> >  __x64_sys_move_pages+0x24/0x30
> >  do_syscall_64+0x5b/0x180
> >  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> >=20
> > To fix, only use page_mapping() for non-anon or file pages.  For anon
> > pages wait until we find a vma in which the page is mapped and get the
> > address_space from vm_file.
> >=20
> > Fixes: b43a99900559 ("hugetlbfs: use i_mmap_rwsem for more pmd sharing
> > synchronization")
> > Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>=20
> Mike,
>=20
> 1) with LTP move_pages12 (MAP_PRIVATE version of reproducer)
> Patch below fixes the panic for me.
> It didn't apply cleanly to latest master, but conflicts were easy to reso=
lve.
>=20
> 2) with MAP_SHARED version of reproducer
> It still hangs in user-space.
> v4.19 kernel appears to work fine so I've started a bisect.

My bisect with MAP_SHARED version arrived at same 2 commits:
  c86aa7bbfd55 hugetlbfs: Use i_mmap_rwsem to fix page fault/truncate race
  b43a99900559 hugetlbfs: use i_mmap_rwsem for more pmd sharing synchroniza=
tion

Maybe a deadlock between page lock and mapping->i_mmap_rwsem?

thread1:
  hugetlbfs_evict_inode
    i_mmap_lock_write(mapping);
    remove_inode_hugepages
      lock_page(page);

thread2:
  __unmap_and_move
    trylock_page(page) / lock_page(page)
      remove_migration_ptes
        rmap_walk_file
          i_mmap_lock_read(mapping);

Here's strace output:
<snip>
1196  11:27:16 mmap(NULL, 4194304, PROT_READ|PROT_WRITE, MAP_SHARED|MAP_ANO=
NYMOUS|MAP_HUGETLB, -1, 0) =3D 0x7f646c400000
1197  11:27:16 set_robust_list(0x7f646d5b0e60, 24) =3D 0
1197  11:27:16 getppid()                =3D 1196
1197  11:27:16 move_pages(1196, 1024, [0x7f646c400000, 0x7f646c401000, 0x7f=
646c402000, 0x7f646c403000, 0x7f646c404000, 0x7f646c405000, 0x7f646c406000,=
 0x7f646c407000, 0x7f646c408000, 0x7f646c409000, 0x7f646c40a000, 0x7f646c40=
b000, 0x7f646c40c000, 0x7f646c40d000, 0x7f646c40e000, 0x7f646c40f000, 0x7f6=
46c410000, 0x7f646c411000, 0x7f646c412000, 0x7f646c413000, 0x7f646c414000, =
0x7f646c415000, 0x7f646c416000, 0x7f646c417000, 0x7f646c418000, 0x7f646c419=
000, 0x7f646c41a000, 0x7f646c41b000, 0x7f646c41c000, 0x7f646c41d000, 0x7f64=
6c41e000, 0x7f646c41f000, ...], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, =
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...], [-ENOENT, -ENOE=
NT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT,=
 -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -E=
NOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOE=
NT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, -ENOENT, ...], MPOL_MF_MOVE_ALL) =
=3D 0
1197  11:27:16 move_pages(1196, 1024, [0x7f646c400000, 0x7f646c401000, 0x7f=
646c402000, 0x7f646c403000, 0x7f646c404000, 0x7f646c405000, 0x7f646c406000,=
 0x7f646c407000, 0x7f646c408000, 0x7f646c409000, 0x7f646c40a000, 0x7f646c40=
b000, 0x7f646c40c000, 0x7f646c40d000, 0x7f646c40e000, 0x7f646c40f000, 0x7f6=
46c410000, 0x7f646c411000, 0x7f646c412000, 0x7f646c413000, 0x7f646c414000, =
0x7f646c415000, 0x7f646c416000, 0x7f646c417000, 0x7f646c418000, 0x7f646c419=
000, 0x7f646c41a000, 0x7f646c41b000, 0x7f646c41c000, 0x7f646c41d000, 0x7f64=
6c41e000, 0x7f646c41f000, ...], [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, =
1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, ...], [1, -EACCES, 1,=
 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,=
 1, 1, 1, 1, ...], MPOL_MF_MOVE_ALL) =3D 0
1197  11:27:16 move_pages(1196, 1024, [0x7f646c400000, 0x7f646c401000, 0x7f=
646c402000, 0x7f646c403000, 0x7f646c404000, 0x7f646c405000, 0x7f646c406000,=
 0x7f646c407000, 0x7f646c408000, 0x7f646c409000, 0x7f646c40a000, 0x7f646c40=
b000, 0x7f646c40c000, 0x7f646c40d000, 0x7f646c40e000, 0x7f646c40f000, 0x7f6=
46c410000, 0x7f646c411000, 0x7f646c412000, 0x7f646c413000, 0x7f646c414000, =
0x7f646c415000, 0x7f646c416000, 0x7f646c417000, 0x7f646c418000, 0x7f646c419=
000, 0x7f646c41a000, 0x7f646c41b000, 0x7f646c41c000, 0x7f646c41d000, 0x7f64=
6c41e000, 0x7f646c41f000, ...], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, =
0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ...],  <unfinished ..=
.>
1196  11:27:16 munmap(0x7f646c400000, 4194304 <unfinished ...>
<hangs>

Regards,
Jan


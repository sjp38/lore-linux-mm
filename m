Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 966E2C433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 22:47:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 47C64206E0
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 22:47:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="EOmDqSUs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 47C64206E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6DB88E0003; Mon, 29 Jul 2019 18:47:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D1EB98E0002; Mon, 29 Jul 2019 18:47:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B97918E0003; Mon, 29 Jul 2019 18:47:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 922FE8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 18:47:32 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id p7so34838873otk.22
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 15:47:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=pGspLfcI5dn5auhu00Bv2+O8qwFw4pt/q/3bCgR/aZw=;
        b=d7EAqyxmjGy6oeM1kkIPDuZsG+TH8PbR275L7JD4aL7iST72bZrr9NDqEXObOk5yb7
         4aPReQiKI2xiNhBnS1v8S8EhjxP5NepIg3BTfFeIIct4diGgsW2bRYba0iRSHqfQN8yH
         BhL7rGTfExcsRg/H2KTfw1HG2V0+Pa5On65EwdokpnpR0eHXq17WN69OkcnA0pJeGksA
         v2SJYxmfJw7EAWVIaxZUI1wKzabz1I+EyNHwB8Tef0Eua30pKbuDS6HJC1mvtmDX5U3C
         aYSMp1BMA1tmB0xco52V/x6O49cQI4R+YkgA9n0qHbGrZ5yxLvCISj0mWuUDY1mnhUBh
         GFiA==
X-Gm-Message-State: APjAAAVONVUZ/cinfOi7CY/ryu8kGzq8o6fe9lZyrDMy645XrEdXJL/K
	IukYgHVKl1mDaZIrMhg70eVoDwrMixkNwjh5Z4jh7y6yOd1Z5zm6lHJ+UHZsIg/XhLvIEKD+bH8
	4II/ZlkSqAMLhIHLXsYGtwNcDaQpOYl3rqdjKGQc73Wl4aXFYunzJYlK6HVpiwq1lsg==
X-Received: by 2002:aca:210f:: with SMTP id 15mr53333339oiz.24.1564440452150;
        Mon, 29 Jul 2019 15:47:32 -0700 (PDT)
X-Received: by 2002:aca:210f:: with SMTP id 15mr53333306oiz.24.1564440451289;
        Mon, 29 Jul 2019 15:47:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564440451; cv=none;
        d=google.com; s=arc-20160816;
        b=nB7KfwIn3Zmr7SUrpMef3Ye+QSBLegcEdK9bAuLuhS+XU1IYQVvXbhAgz3rhBaFDUJ
         JWIjhRepNDdVabHpVLFhSJafwu6nU4nTMErC/PuhriF8WE7gwM8DiZw3RujeHFX20QeQ
         dxbkX/YIJn5/4N+AvxKj9mGp0wvQKsj6k+Pim92gPWhjUTsArJ2Jggpqyts/mHFOyhEu
         mUrT9CnwTuL8jdnIH/45S0loizx47yNorgWGXNcSdahwKeeC/naiNgNq459upIlhHzX7
         Ul+I+1ukEuhMlBF2oyG85ZgUjixO/MIhdNqQnjxzbN7Zs1OmIZ5+37pgeuSsWyYJwuRI
         2bgw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=pGspLfcI5dn5auhu00Bv2+O8qwFw4pt/q/3bCgR/aZw=;
        b=nPSY+rBCo+Z7n6EZ5MLCIZ0QG9ToMrxnGQOxTJYm7arETkdO048anqMhG4VL7eXDUq
         B2iUIK7Ns/bFhT3mvEyFv835HP0yMXxLRRFkCCCXoc2aD+HOPLH9bKRNIDLcKz7mbdGn
         HFsXhqn4qq6yVMw0Wgz0XuP7+NgzhnSrB+lpeKGzYTl8CI3i+pRlbWtN+QSjzLbX0uJ+
         NTaYSiw7X8CX1yrRVM/wBzFxExhq+I4Q6yvSJqz6vmKkO3jr1VyKfNHLPt/HqbvRA6jz
         RTaIkbfrnWiW4noqIkb+XXTMVge05CeZ3LRJmDnaX8sbZocMQwu6B9tbY8Mu7oKl37MB
         ef6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=EOmDqSUs;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 2sor32220995ots.16.2019.07.29.15.47.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 Jul 2019 15:47:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=EOmDqSUs;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=pGspLfcI5dn5auhu00Bv2+O8qwFw4pt/q/3bCgR/aZw=;
        b=EOmDqSUs6hF+pZuWJuftA9aPq6cFQag5ny9EnkBeJ52z+kxmdOlolee9p59Vu9GLYe
         azUD+vpI7tLeFRzKlDoIn1egahB1uqvzdlbrjizMxUW9A/UwDxtf59CDnUSZTPl8LQe/
         PZ5l7VAae/xLJ7a0946KkLsLEKwTX4hwTuIKJbUbez6hGUeF+2lprVVNoJfkMUKUZPr9
         gyGVmD4remu6IJFA2BYiQiQS5pQMU813zUOs+aqX/5MaDBg6hK7eLjSpYQGRQeJbjA+o
         hLgWlZp6LgSWIhDLY2jJe1zfQDuYGhMsFk5O28Dd2PAzOdfBfliNHLKqJmh5a7avY4bc
         ajMA==
X-Google-Smtp-Source: APXvYqwHhK0pqI+UxAUN6eAkNnP/kNGmpG2YxVMQQM9wqFP7fHOj5FZgU+QRymxyn7zomdaevLtN1Er7dDlil0CjgHA=
X-Received: by 2002:a9d:7a9a:: with SMTP id l26mr7501139otn.71.1564440450856;
 Mon, 29 Jul 2019 15:47:30 -0700 (PDT)
MIME-Version: 1.0
References: <20190729210933.18674-1-william.kucharski@oracle.com> <20190729210933.18674-3-william.kucharski@oracle.com>
In-Reply-To: <20190729210933.18674-3-william.kucharski@oracle.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 29 Jul 2019 15:47:18 -0700
Message-ID: <CAPcyv4ixiBOXz97iZV2ARp8Uqwk2BbEW+5Q6e3vfAjv8LToPfw@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] mm,thp: Add experimental config option RO_EXEC_FILEMAP_HUGE_FAULT_THP
To: William Kucharski <william.kucharski@oracle.com>
Cc: ceph-devel@vger.kernel.org, linux-afs@lists.infradead.org, 
	linux-btrfs@vger.kernel.org, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Netdev <netdev@vger.kernel.org>, Chris Mason <clm@fb.com>, 
	"David S. Miller" <davem@davemloft.net>, David Sterba <dsterba@suse.com>, 
	Josef Bacik <josef@toxicpanda.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Song Liu <songliubraving@fb.com>, Bob Kasten <robert.a.kasten@intel.com>, 
	Mike Kravetz <mike.kravetz@oracle.com>, Chad Mynhier <chad.mynhier@oracle.com>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <jweiner@fb.com>, 
	Matthew Wilcox <willy@infradead.org>, Dave Airlie <airlied@redhat.com>, 
	Vlastimil Babka <vbabka@suse.cz>, Keith Busch <keith.busch@intel.com>, 
	Ralph Campbell <rcampbell@nvidia.com>, Steve Capper <steve.capper@arm.com>, 
	Dave Chinner <dchinner@redhat.com>, Sean Christopherson <sean.j.christopherson@intel.com>, 
	Hugh Dickins <hughd@google.com>, Ilya Dryomov <idryomov@gmail.com>, 
	Alexander Duyck <alexander.h.duyck@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Amir Goldstein <amir73il@gmail.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@suse.com>, 
	Jann Horn <jannh@google.com>, David Howells <dhowells@redhat.com>, 
	John Hubbard <jhubbard@nvidia.com>, Souptick Joarder <jrdr.linux@gmail.com>, 
	"john.hubbard@gmail.com" <john.hubbard@gmail.com>, Jan Kara <jack@suse.cz>, 
	Andrey Konovalov <andreyknvl@google.com>, Arun KS <arunks@codeaurora.org>, 
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Jeff Layton <jlayton@kernel.org>, 
	Yangtao Li <tiny.windzz@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Robin Murphy <robin.murphy@arm.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	David Rientjes <rientjes@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Yafang Shao <laoar.shao@gmail.com>, Huang Shijie <sjhuang@iluvatar.ai>, 
	Yang Shi <yang.shi@linux.alibaba.com>, Miklos Szeredi <mszeredi@redhat.com>, 
	Pavel Tatashin <pasha.tatashin@oracle.com>, Kirill Tkhai <ktkhai@virtuozzo.com>, 
	Sage Weil <sage@redhat.com>, Ira Weiny <ira.weiny@intel.com>, 
	"Darrick J. Wong" <darrick.wong@oracle.com>, Gao Xiang <hsiangkao@aol.com>, 
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Ross Zwisler <zwisler@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 29, 2019 at 2:10 PM William Kucharski
<william.kucharski@oracle.com> wrote:
>
> Add filemap_huge_fault() to attempt to satisfy page faults on
> memory-mapped read-only text pages using THP when possible.
>
> Signed-off-by: William Kucharski <william.kucharski@oracle.com>
[..]
> +/**
> + * filemap_huge_fault - read in file data for page fault handling to THP
> + * @vmf:       struct vm_fault containing details of the fault
> + * @pe_size:   large page size to map, currently this must be PE_SIZE_PMD
> + *
> + * filemap_huge_fault() is invoked via the vma operations vector for a
> + * mapped memory region to read in file data to a transparent huge page during
> + * a page fault.
> + *
> + * If for any reason we can't allocate a THP, map it or add it to the page
> + * cache, VM_FAULT_FALLBACK will be returned which will cause the fault
> + * handler to try mapping the page using a PAGESIZE page, usually via
> + * filemap_fault() if so speicifed in the vma operations vector.
> + *
> + * Returns either VM_FAULT_FALLBACK or the result of calling allcc_set_pte()
> + * to map the new THP.
> + *
> + * NOTE: This routine depends upon the file system's readpage routine as
> + *       specified in the address space operations vector to recognize when it
> + *      is being passed a large page and to read the approprate amount of data
> + *      in full and without polluting the page cache for the large page itself
> + *      with PAGESIZE pages to perform a buffered read or to pollute what
> + *      would be the page cache space for any succeeding pages with PAGESIZE
> + *      pages due to readahead.
> + *
> + *      It is VITAL that this routine not be enabled without such filesystem
> + *      support.

Rather than a hopeful comment, this wants an explicit mechanism to
prevent inadvertent mismatched ->readpage() assumptions. Either a new
->readhugepage() op, or a flags field in 'struct
address_space_operations' indicating that the address_space opts into
being careful to handle huge page arguments. I.e. something like
mmap_supported_flags that was added to 'struct file_operations'.


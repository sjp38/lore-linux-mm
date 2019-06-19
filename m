Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7291C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:51:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 89D432084A
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:51:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 89D432084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16B368E0003; Wed, 19 Jun 2019 02:51:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11CC78E0001; Wed, 19 Jun 2019 02:51:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 009A08E0003; Wed, 19 Jun 2019 02:51:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A3C9F8E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:51:18 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i9so24758327edr.13
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:51:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=AKspm/A14cLIWH1I4dEssx9+kg3NE1BUvsS6Y7EDPxU=;
        b=Ab8/TjC1w2TA/lZoGtgPkLa5d5oAWmPEmaccFNDrxgRwtwuwtRByIzBsAxq04ByVV1
         LzdM3Nsqbr2NJpqnEfn2cVwfFm3O1OtF9DFXaGBdcHyXIiD8ENM9HhCCJawj3T0cLwWI
         LcKettmTuPBP+MHgy89C6TRR8rlQCC7SZQklddBad77cTHmjsxcQdzbH0dJUmaTCPaQ2
         PZEtZmNhU5cWloGaKVP36B5FKKVof3Q7ItniqBFI732k5C/4Y1S2HiX+I7gcc1e/5hoh
         JpAVqikk3zQ1R+TocgfQ2TX+h01dweu5b24/iznqonSMcfuLCv5rD6uUX42UdPyrY1b6
         6zsA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAU/YScErrntdSd+twTh9lUZzOnOaZAR925cp16jgz8aKxrXbPNE
	aqgOb8cvUWtS0R6ZO3LWTONn0EU69gHfSd3SnKiR0/Rep1dlpstXke4qbaJgFq6/I3Fkfr6SiVp
	Thk5dOcgjFey9yttd95WHH7kONNGYzCJOiYrFg427Y9kUe7MSJcup4tTkDJOFSTs=
X-Received: by 2002:a50:a56b:: with SMTP id z40mr79715279edb.99.1560927078237;
        Tue, 18 Jun 2019 23:51:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5ppU5BNBueaJOqIeVErh1YnIvzdx2ZWYjqSriFPY4K3L93VGzpDqwVDkfdsGrkBYkg3eJ
X-Received: by 2002:a50:a56b:: with SMTP id z40mr79715237edb.99.1560927077521;
        Tue, 18 Jun 2019 23:51:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560927077; cv=none;
        d=google.com; s=arc-20160816;
        b=wLQ82+PgekafY2e3goFWDv+9xhpfzXZgQFpaaqmqHuwVaHwVMglLyuE1N7NAG4rH/K
         sSp+4ztsas7RmpTH5UCj/JGS2GgROVUw3Llf+j/YaZ4hwmR0LP4gqZ+fZJLJUUM73Zbo
         B98OBgeiAXsN2gJOfi8YmmxW6EqPOmVgTEOSxGf7EWeSkmmsAJ4OLMoiihegIpeBn7cK
         wcvKz95uNQDaqI9lA7jpHwzwn/e8lFnDCFnMPOo41d7jg+ec0OMSWSixqqQvp17rfMF8
         W59Yc4eXKzcZH8JrZw/h6O3SAPGYJQy1v011SCMiTr4cIcDxH4iOuJhESbv52Nq8UnUp
         vAIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=AKspm/A14cLIWH1I4dEssx9+kg3NE1BUvsS6Y7EDPxU=;
        b=vfWoNSOcqJppmAcmjj9qGz+eETPFwX6TUy+gqC8VHpHW9fBuZn+rMAaEfHIKVqqBaZ
         H/z63bvWGRbDsTTEbxwtlLF9CO329CZNTN7KebzV8HvPAQ+288oEvpbOp0Vxgoe3pGdU
         Tm9ZvocP2MjDqrvKW7pkb7LvMKoI2i3nzxpC6pPPF0wE1mbG0lg+hJWNTgPH+OIBFhk2
         lWt2btRdb4//WqAKwE48q5/LavZhCMttSuIpFShmpxPP6B5vs8PoRMz5YJtCMrFa+P+r
         jajshf9+qnWTvfvVDEcuZBOwLqc+FPuOoValw0qXVxg5YKL7mcfDIdYZ0AN6R1fMxeuu
         YiUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 57si14271010edz.69.2019.06.18.23.51.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:51:17 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B6765AF97;
	Wed, 19 Jun 2019 06:51:16 +0000 (UTC)
Date: Wed, 19 Jun 2019 08:51:14 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Song Liu <songliubraving@fb.com>
Cc: linux-mm@kvack.org, matthew.wilcox@oracle.com,
	kirill.shutemov@linux.intel.com, kernel-team@fb.com,
	william.kucharski@oracle.com, akpm@linux-foundation.org,
	linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v3 0/6] Enable THP for text section of non-shmem files
Message-ID: <20190619065114.GD2968@dhcp22.suse.cz>
References: <20190619062424.3486524-1-songliubraving@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190619062424.3486524-1-songliubraving@fb.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[Cc fsdevel and lkml]

On Tue 18-06-19 23:24:18, Song Liu wrote:
> Changes v2 => v3:
> 1. Removed the limitation (cannot write to file with THP) by truncating
>    whole file during sys_open (see 6/6);
> 2. Fixed a VM_BUG_ON_PAGE() in filemap_fault() (see 2/6);
> 3. Split function rename to a separate patch (Rik);
> 4. Updated condition in hugepage_vma_check() (Rik).
> 
> Changes v1 => v2:
> 1. Fixed a missing mem_cgroup_commit_charge() for non-shmem case.
> 
> This set follows up discussion at LSF/MM 2019. The motivation is to put
> text section of an application in THP, and thus reduces iTLB miss rate and
> improves performance. Both Facebook and Oracle showed strong interests to
> this feature.
> 
> To make reviews easier, this set aims a mininal valid product. Current
> version of the work does not have any changes to file system specific
> code. This comes with some limitations (discussed later).
> 
> This set enables an application to "hugify" its text section by simply
> running something like:
> 
>           madvise(0x600000, 0x80000, MADV_HUGEPAGE);
> 
> Before this call, the /proc/<pid>/maps looks like:
> 
>     00400000-074d0000 r-xp 00000000 00:27 2006927     app
> 
> After this call, part of the text section is split out and mapped to
> THP:
> 
>     00400000-00425000 r-xp 00000000 00:27 2006927     app
>     00600000-00e00000 r-xp 00200000 00:27 2006927     app   <<< on THP
>     00e00000-074d0000 r-xp 00a00000 00:27 2006927     app
> 
> Limitations:
> 
> 1. This only works for text section (vma with VM_DENYWRITE).
> 2. Original limitation #2 is removed in v3.
> 
> We gated this feature with an experimental config, READ_ONLY_THP_FOR_FS.
> Once we get better support on the write path, we can remove the config and
> enable it by default.
> 
> Tested cases:
> 1. Tested with btrfs and ext4.
> 2. Tested with real work application (memcache like caching service).
> 3. Tested with "THP aware uprobe":
>    https://patchwork.kernel.org/project/linux-mm/list/?series=131339
> 
> Please share your comments and suggestions on this.
> 
> Thanks!
> 
> Song Liu (6):
>   filemap: check compound_head(page)->mapping in filemap_fault()
>   filemap: update offset check in filemap_fault()
>   mm,thp: stats for file backed THP
>   khugepaged: rename collapse_shmem() and khugepaged_scan_shmem()
>   mm,thp: add read-only THP support for (non-shmem) FS
>   mm,thp: handle writes to file with THP in pagecache
> 
>  fs/inode.c             |   3 ++
>  fs/proc/meminfo.c      |   4 ++
>  include/linux/fs.h     |  31 ++++++++++++
>  include/linux/mmzone.h |   2 +
>  mm/Kconfig             |  11 +++++
>  mm/filemap.c           |   9 ++--
>  mm/khugepaged.c        | 104 +++++++++++++++++++++++++++++++++--------
>  mm/rmap.c              |  12 +++--
>  mm/truncate.c          |   7 ++-
>  mm/vmstat.c            |   2 +
>  10 files changed, 156 insertions(+), 29 deletions(-)
> 
> --
> 2.17.1

-- 
Michal Hocko
SUSE Labs


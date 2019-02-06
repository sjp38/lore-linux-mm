Return-Path: <SRS0=Gu5B=QN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1FD61C282CC
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 13:00:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1CA42073D
	for <linux-mm@archiver.kernel.org>; Wed,  6 Feb 2019 13:00:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=szeredi.hu header.i=@szeredi.hu header.b="ECTFOsBk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1CA42073D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=szeredi.hu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A6DA8E00C0; Wed,  6 Feb 2019 08:00:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67C648E00AA; Wed,  6 Feb 2019 08:00:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 592CA8E00C0; Wed,  6 Feb 2019 08:00:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 31D1D8E00AA
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 08:00:49 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id m128so4422655itd.3
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 05:00:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:from:date:message-id
         :subject:to:cc:content-transfer-encoding;
        bh=fOIQJZI5ixQwS/lmnoBCYM2uMl/vkq4KxqXJU++gt3U=;
        b=ZKbVdq/IOALwj8AaSTKKa14pFxWh/rXXzbO/1EBP9tdGfzpCRQS14AV3l54WtnFDh9
         VzquVdlSqygSPGHhf6YSvpxrC4tFRDrWJ3MgzRDWPsWVLh0uIorZ53Q0gLrUmKi5xUW1
         RuahborPCFVaE/OS0QWAiCsiFX20N9b8rZWCfDFeuTmZkFOGpWFInjFfb4BOTtXI8hnX
         7Z31QYv3OGeQ3/nvJzRKBeBBB8uARbmkzVqMhcfPml9+5KjNv90NzSCXzDus+aTuzOZi
         jgnWZaFFPKeyjW0sjOKUITYCQqdMrbgqoz0uaUbpw6LfUvXVObTl7+gKtDHH+S09mUHK
         ZvMQ==
X-Gm-Message-State: AHQUAuZBVEdKmfvCsKVn/WXBvpkvz0YgGVjMd2G15BA2N5+fGefeFBoZ
	xrarqhohuOfisvNEUNWFgxcSkjHA1fRI/+/OhJ7sV/GZ64L9gjmWneDNlDNlK4rEWjYaFo747i8
	wQ9Li30GyqsY/TT5JLttCMA1NkDLNDq1ZHUzDb1Tre2UQKvx0HqrIDSCeu+IjSIsh7BWKwb8Uof
	H8Us5pJ4TExICy1RrCTQVWnr8jSf8q8nSyiAbA5peBl6Uf/cJDiao8KzHv6kqdNidbkHkNw4q0z
	2ZCAgLtQcMkTsBIcrBEl2YWZz4elC5mWItzD1npVO3aBialVrSvHQ5Gs9/2RNNyWmm6v6qpNE9u
	cYrXNyhDIa733DHxH5Bx8OlKuunH//4J7g+/0NywrM1tOSyRtESPLie8tYkpwr0otPeX6UGjfKm
	u
X-Received: by 2002:a24:298f:: with SMTP id p137mr1940226itp.4.1549458048894;
        Wed, 06 Feb 2019 05:00:48 -0800 (PST)
X-Received: by 2002:a24:298f:: with SMTP id p137mr1940184itp.4.1549458047987;
        Wed, 06 Feb 2019 05:00:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549458047; cv=none;
        d=google.com; s=arc-20160816;
        b=RBQ05whKt7QOcR7ZjDb74IzQ2IvAugv9eFdPbVDlITDEdudYtFcBG/0sM7RACVzgKs
         nzxyFlaajImhUTHIqE9i5tBeo54UpI93itoQSXrXbsNlkeTnR+TNkL0ilNtQi2/ClvSK
         bNcow9+ETi14pZhlkoUVP4Prg+6iH37Xb2u1w8P3bi3Ckl1R8RG65XW8GHo6sZeqABEQ
         F64wlGVzSy91FFdVN2pQBsvLm5Xr4dKe8tA5RkocFHNBOh0RjHsmEsPN6BmAZsYk1H+D
         8B55hPdnjBWVd9qmPj+YZ1bHNs4L/QZw/5F3HBKRviq8qXp4IjPZVTwl6YrlqJUpgS57
         BPwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :mime-version:dkim-signature;
        bh=fOIQJZI5ixQwS/lmnoBCYM2uMl/vkq4KxqXJU++gt3U=;
        b=A+hK0cuNZF9zNqmzTkiWZolXhRl4iBTGnRdXY2mZF3rYJDljbD2LHOO1jtpmzg+98+
         5sVA7x+iDboOOx2ZWrC2se6zydY+vmjarm82fq32rjZ2j4NCom5YlXTHlcQte74NV0L7
         3wVVqwYs5X7gypmfwyIy4ridkoF3xjQD9L8O6ic3VxsUoREsBKhfueHUxFdUIsbm2Q0v
         4GxinvUWpVn+YMhYu/yG8trBzlGDqNBKWQbUBaBRjJ8h6OOwV9UCi/rJPb14oLf6s6hE
         G25AgcZDkTsIYjmE1AL7OXqxjRiEwHtLr/PPfb3QrOt+pCvNnonRpwnkTrFNmbp6mK+A
         CrWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=temperror (no key for signature) header.i=@szeredi.hu header.s=google header.b=ECTFOsBk;
       spf=pass (google.com: domain of miklos@szeredi.hu designates 209.85.220.65 as permitted sender) smtp.mailfrom=miklos@szeredi.hu
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f24sor3514526iog.48.2019.02.06.05.00.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Feb 2019 05:00:47 -0800 (PST)
Received-SPF: pass (google.com: domain of miklos@szeredi.hu designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=temperror (no key for signature) header.i=@szeredi.hu header.s=google header.b=ECTFOsBk;
       spf=pass (google.com: domain of miklos@szeredi.hu designates 209.85.220.65 as permitted sender) smtp.mailfrom=miklos@szeredi.hu
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=szeredi.hu; s=google;
        h=mime-version:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=fOIQJZI5ixQwS/lmnoBCYM2uMl/vkq4KxqXJU++gt3U=;
        b=ECTFOsBkpy73B8UftN2IbIv75uXdlaVeKOnc3zYw/tqRhDaD7/O8CAREku75naTBRa
         0C+V7FyVxsXlT2mTIhkIYIwK7+jLaRIc2LBxIL5fWAVnIl+GV0r8gtyL0JRt0f0rrQC0
         +NS0IbKnAeGKpn59wi5a6cHaHgT7yeOGRz+hc=
X-Google-Smtp-Source: AHgI3Iavku+34l9vp8gYIesHqSALvNmE/GBbVmEjNjRvFj+8QeGoS/qkh4yFScCgAMrZ6N5iOxOiRXQJY8pcO75c9Dw=
X-Received: by 2002:a6b:e506:: with SMTP id y6mr176263ioc.246.1549458046738;
 Wed, 06 Feb 2019 05:00:46 -0800 (PST)
MIME-Version: 1.0
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Wed, 6 Feb 2019 14:00:35 +0100
Message-ID: <CAJfpeguq60X745NnYDAKZhodLEvFRha2QTpAu6g63vJxq8SvaQ@mail.gmail.com>
Subject: [LSF/MM TOPIC] filesystem virtualization
To: lsf-pc@lists.linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, 
	Vivek Goyal <vgoyal@redhat.com>, Stefan Hajnoczi <stefanha@redhat.com>, 
	"Dr. David Alan Gilbert" <dgilbert@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.045813, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a joint topic proposal with Vivek Goyal.

Discuss remaining issues related to exporting a filesystem from host to
guest (see virtio-fs prototype posting[1] for more background):

* How to provide strong coherency guarantees?

   - Fsnotify synchronous post op notification
   - Extend lease (delegation) API to userspace
   - Multi-component path revalidation

* Issues related to c/m/atime handling:

   - Clock synchronization between host and guest (not an fs issue, but fs
     has to deal with lack of it)

   - Could we have O_NOCMTIME open flag?

* Shared access to file data:

   - Use DAX in guest to access host page cache (mmap/munmap sections of
     file in guest address space; happens dynamically on a need basis); is
     this design reasonable?

   - Avoids memory copies and cache duplication, but host page table setup
     may have high cost.  Can that be improved?  (E.g. fault-ahead)

   - Too many VMA=E2=80=99s on host per qemu instance?

* File locking:

   - Host API for POSIX lock sharing?

* Ideas for the future:

   - Buffering directory operations (e.g. "tar xfz ..." with as few
     synchronous ops as possible)

[1] https://lore.kernel.org/lkml/20181210171318.16998-1-vgoyal@redhat.com/


Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A076C282C4
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 00:27:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3E1D9222BE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 00:27:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="A75fEOe9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3E1D9222BE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E44DB8E0003; Tue, 12 Feb 2019 19:27:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF4138E0001; Tue, 12 Feb 2019 19:27:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D0C2E8E0003; Tue, 12 Feb 2019 19:27:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id A53548E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 19:27:33 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id j23so581359otl.6
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 16:27:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=y2TCsZERRG+6EYzxN92qIb/n/TWRZq+et/eHaEh69F0=;
        b=ewdgXycaQb5Pdr6WDTFvjkVRfjvDFmryUG+RjUQeMZjxOZXLsXIEt3W+drCdGRwwFv
         YX1YPLbII/z4WR6jJWMc+FkyBEy5xth5yCyftkSYU6nNLYzYLDFRXkl2UPkMjABU8nbK
         p8m51jA5gduMR3V8L5FYLNLjjFxbOKZBLnb6xBQq7buoVn4NA/Mdar/mTHxmZkoVQbol
         SIt8uScI3dGDq5219HLkSgyMYrhqCBZdjwmB6FSSV0jGSw+57I4CVo/Lg1hTADognryD
         vd1Ez51MDEBR+TPXaBibPZzSTHXk+BDNGL2yo/srOF1zxCmO7IJWttbEQaZtnDtkDw5w
         Hrjw==
X-Gm-Message-State: AHQUAua39bEwDvuk7QbanvFID+ThhrrjqOiRDfWUlHczNr2nLqy/Thm1
	cFcm3YiwvjqMYldGxeIl7PwiI6gjSEDI7R0TAmo7FwkHEyogwCn80iUVLL5mOazrbs95w6E4NGS
	NvRQZjMXnnp71U8OIqXAB7e5gCRUlLiMonhNgaDh3KYK+bWvdqBTl0aRBrA/rDTZbBLdqtA+kqu
	aRjI8zTd8Fr7lE0zxYTDZpUEYgEakkbKQa0o/4dGxQ8a3ZXLaIhed5Lk0xEZ+xsDQfelJMipy4S
	HGDH5oee16lVifS6sbNopvGogTLh1ZAgmb34QtsIHiWFBbzSGs11SwuKDlo9P3jEvcbEAICpKf9
	4ab1gaWGJRJwmpFOFjsi+N4uQF+BiugG17OGtnfeUBn00wOIJB8udfXmpAF5Sbzba/H4iYVEfiI
	D
X-Received: by 2002:a9d:5f85:: with SMTP id g5mr41013oti.333.1550017653422;
        Tue, 12 Feb 2019 16:27:33 -0800 (PST)
X-Received: by 2002:a9d:5f85:: with SMTP id g5mr40979oti.333.1550017652642;
        Tue, 12 Feb 2019 16:27:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550017652; cv=none;
        d=google.com; s=arc-20160816;
        b=eDHMM7EjjzkOWjD34ZchnXJ3m8VfPz3Hy1J4dOlNIA/dmG6dMG3r6wbciK7WWLrpeF
         rJL89eM9o0J+OSd/dnO7wcyr3Hx7/5veZYeaXHw/fLNkQezePCdqMvsZTK0p/WAVTGiq
         bQjwTLhKzGi4TedrX4xUqZhG1/0S4Ae65onXMnadnKiVi0ClrbCrLp2WSXfyNbbuGFeP
         45HByhunQEUSzW9kVB31QJvn5eGxyljYq90XQDFNpgFL0sfp1+O2V0p3Q+NuHPrNZHIC
         oCgW04GFXRCfGGNluzw7jS0j7g1zG907olvJFIXUUeVy3ZU7kLgvVR4CuZcgNzTIB3Ys
         72xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=y2TCsZERRG+6EYzxN92qIb/n/TWRZq+et/eHaEh69F0=;
        b=NXAWpKABd3N+qr7rmDX+rUvSFZjPvWqU4X8uGpyn1M9xBPy+L4+wqynBjKTV80CXDL
         XfkRt/J1jnQsnPkihmtjxNl+yJmO4mOExW4aacWcAdtGBR7YQFD0SxW5PMy47YZtioPL
         RcOcZ/QyUjy1XUJIr10P2UfZCQOV/57XOqgvZBkRCUmrz6XSvzdUqLJOCk1ZnZMcnUwU
         FRqTJmxaHDMZQ1FajdtZAVPiFDkn8lmg0DpB+bAjM+mkO2CgKulnTIXatWCr12HUwjkO
         T3M6Aktg8sEuvMBKAeHtsvugIGXhVYDQl5oCQ9wc887E96a/rwheG2Dun/qMEhaNk+ML
         PlPw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=A75fEOe9;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j11sor3118405otn.96.2019.02.12.16.27.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Feb 2019 16:27:32 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=A75fEOe9;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=y2TCsZERRG+6EYzxN92qIb/n/TWRZq+et/eHaEh69F0=;
        b=A75fEOe9R90kV2GScPTNMAUPngiL+eNMY0oZ0OKHPk5OztxH9Df7c6sM0DuZCgI60/
         5Mb1cu6iCxdd6riY0ClnsLL3/8Ym8StuKIcf46LFb3QUwVgL4LdKmvTtoQUq7aD6++wq
         TPgiQ6QMgWwm+T+DuD36275BXXGaVy/HcxsRpaG87l54O4IbIAjgxb2GSF0T6onLjw5P
         WrneLaFVMEke/K5DgHV+Hjylb4RGHX+lu4mahDLCGqJJxlOR6xjuMezGYPMrdHgmLgtz
         imyROKKwGwMBrK3e5BDamtqLCRgAkiqzBcqmfdsHTJtoh+Y/Cqyyk6nQf0kzwZGl2fqi
         IJYQ==
X-Google-Smtp-Source: AHgI3IbnvF7P5f16Hzx1P+INe5f+ZZu/+RzqOFetn+03YPaE7a/8n1/bJKYqMcDXqTJojYjxvyFnq/ZoJZouHT3V88c=
X-Received: by 2002:a9d:37b7:: with SMTP id x52mr6870269otb.214.1550017652285;
 Tue, 12 Feb 2019 16:27:32 -0800 (PST)
MIME-Version: 1.0
References: <788d7050-f6bb-b984-69d9-504056e6c5a6@intel.com> <20190212235114.GM20493@dastard>
In-Reply-To: <20190212235114.GM20493@dastard>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 12 Feb 2019 16:27:20 -0800
Message-ID: <CAPcyv4jhbYfrdTOyh90-u-gEUV7QEgF_HrNid5w5WbPPGr=axw@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Memory Encryption on top of filesystems
To: Dave Chinner <david@fromorbit.com>
Cc: Dave Hansen <dave.hansen@intel.com>, lsf-pc@lists.linux-foundation.org, 
	linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	"Shutemov, Kirill" <kirill.shutemov@intel.com>, 
	"Schofield, Alison" <alison.schofield@intel.com>, "Darrick J. Wong" <darrick.wong@oracle.com>, 
	Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 3:51 PM Dave Chinner <david@fromorbit.com> wrote:
>
> On Tue, Feb 12, 2019 at 08:55:57AM -0800, Dave Hansen wrote:
> > Multi-Key Total Memory Encryption (MKTME) [1] is feature of a memory
> > controller that allows memory to be selectively encrypted with
> > user-controlled key, in hardware, at a very low runtime cost.  However,
> > it is implemented using AES-XTS which encrypts each block with a key
> > that is generated based on the physical address of the data being
> > encrypted.  This has nice security properties, making some replay and
> > substitution attacks harder, but it means that encrypted data can not b=
e
> > naively relocated.
>
> The subject is "Memory Encryption on top of filesystems", but really
> what you are talking about is "physical memory encryption /below/
> filesystems".
>
> i.e. it's encryption of the physical storage the filesystem manages,
> not encryption within the fileystem (like fscrypt) or or user data
> on top of the filesystem (ecryptfs or userspace).
>
> > Combined with persistent memory, MKTME allows data to be unlocked at th=
e
> > device (DIMM or namespace) level, but left encrypted until it actually
> > needs to be used.
>
> This sounds more like full disk encryption (either in the IO
> path software by dm-crypt or in hardware itself), where the contents
> are decrypted/encrypted in the IO path as the data is moved between
> physical storage and the filesystem's memory (page/buffer caches).
>
> Is there any finer granularity than a DIMM or pmem namespace for
> specifying encrypted regions? Note that filesystems are not aware of
> the physical layout of the memory address space (i.e. what DIMM
> corresponds to which sector in the block device), so DIMM-level
> granularity doesn't seem particularly useful right now....
>
> Also, how many different hardware encryption keys are available for
> use, and how many separate memory regions can a single key have
> associated with it?
>
> > However, if encrypted data were placed on a
> > filesystem, it might be in its encrypted state for long periods of time
> > and could not be moved by the filesystem during that time.
>
> I'm not sure what you mean by "if encrypted data were placed on a
> filesystem", given that the memory encryption is transparent to the
> filesystem (i.e. happens in the memory controller on it's way
> to/from the physical storage).
>
> > The =E2=80=9Ceasy=E2=80=9D solution to this is to just require that the=
 encryption key
> > be present and programmed into the memory controller before data is
> > moved.  However, this means that filesystems would need to know when a
> > given block has been encrypted and can not be moved.
>
> I'm missing something here - how does the filesystem even get
> mounted if we haven't unlocked the device the filesystem is stored
> on? i.e. we need to unlock the entire memory region containing the
> filesystem so it can read and write it's metadata (which can be
> randomly spread all over the block device).
>
> And if we have to do that to mount the filesystem, then aren't we
> also unlocking all the same memory regions that contain user data
> and hence they can be moved?

Yes, and this is the most likely scenario for enabling MKTME with
persistent memory. The filesystem will not be able to mount until the
entire physical address range (namespace device) is unlocked, and the
filesystem is kept unaware of the encryption. One key per namespace
device.

> At what point do we end up with a filesystem mounted and trying to
> access a locked memory region?

Another option is to enable encryption to be specified at mmap time
with the motivation of being able to use the file system for
provisioning instead of managing multiple namespaces. The filesystem
would need to be careful to use the key for any physical block
management, and a decision would need to be made about when/whether
read(2)/write(2) access cipher text . The current thinking is that
this would be too invasive / restrictive for the filesystem, but it's
otherwise an interesting thought experiment for allowing the
filesystem to take on more physical-storage allocation
responsibilities.


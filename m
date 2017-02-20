Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 05BD86B0038
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 00:03:47 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id c193so70864832pfb.7
        for <linux-mm@kvack.org>; Sun, 19 Feb 2017 21:03:46 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id 7si6112821pfd.172.2017.02.19.21.03.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Feb 2017 21:03:45 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: Is MADV_HWPOISON supposed to work only on faulted-in pages?
Date: Mon, 20 Feb 2017 05:00:17 +0000
Message-ID: <20170220050016.GA15533@hori1.linux.bs1.fc.nec.co.jp>
References: <6a445beb-119c-9a9a-0277-07866afe4924@redhat.com>
In-Reply-To: <6a445beb-119c-9a9a-0277-07866afe4924@redhat.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <4A20DC0DB9C13C4E90784422FFC7E6D8@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Stancek <jstancek@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "ltp@lists.linux.it" <ltp@lists.linux.it>

On Tue, Feb 14, 2017 at 04:41:29PM +0100, Jan Stancek wrote:
> Hi,
>
> code below (and LTP madvise07 [1]) doesn't produce SIGBUS,
> unless I touch/prefault page before call to madvise().
>
> Is this expected behavior?

Thank you for reporting.

madvise(MADV_HWPOISON) triggers page fault when called on the address
over which no page is faulted-in, so I think that SIGBUS should be
called in such case.

But it seems that memory error handler considers such a page as "reserved
kernel page" and recovery action fails (see below.)

  [  383.371372] Injecting memory failure for page 0x1f10 at 0x7efcdc569000
  [  383.375678] Memory failure: 0x1f10: reserved kernel page still referen=
ced by 1 users
  [  383.377570] Memory failure: 0x1f10: recovery action for reserved kerne=
l page: Failed

I'm not sure how/when this behavior was introduced, so I try to understand.
IMO, the test code below looks valid to me, so no need to change.

Thanks,
Naoya Horiguchi

>
> Thanks,
> Jan
>
> [1] https://github.com/linux-test-project/ltp/blob/master/testcases/kerne=
l/syscalls/madvise/madvise07.c
>
> -------------------- 8< --------------------
> #include <stdlib.h>
> #include <sys/mman.h>
> #include <unistd.h>
>
> int main(void)
> {
> 	void *mem =3D mmap(NULL, getpagesize(), PROT_READ | PROT_WRITE,
> 			MAP_ANONYMOUS | MAP_PRIVATE /*| MAP_POPULATE*/,
> 			-1, 0);
>
> 	if (mem =3D=3D MAP_FAILED)
> 		exit(1);
>
> 	if (madvise(mem, getpagesize(), MADV_HWPOISON) =3D=3D -1)
> 		exit(1);
>
> 	*((char *)mem) =3D 'd';
>
> 	return 0;
> }
> -------------------- 8< --------------------
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

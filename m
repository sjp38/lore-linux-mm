Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 4E9056B0031
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 21:03:05 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ma3so8857183pbc.13
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 18:03:04 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id x5si9792879pax.64.2014.04.14.18.03.03
        for <linux-mm@kvack.org>;
        Mon, 14 Apr 2014 18:03:04 -0700 (PDT)
Message-ID: <534C8534.6080008@cn.fujitsu.com>
Date: Tue, 15 Apr 2014 09:02:44 +0800
From: "gux.fnst" <gux.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: ask for your help about a patch (commit: 9845cbb)
References: <534B46FE.1070704@cn.fujitsu.com> <20140414103747.70943E0098@blue.fi.intel.com>
In-Reply-To: <20140414103747.70943E0098@blue.fi.intel.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: linux-mm@kvack.org


On 04/14/2014 06:37 PM, Kirill A. Shutemov wrote:
> gux.fnst wrote:
>> Hi Kirill,
> Hi Xing,
>
> Please always CC to mailing list for upstream-related questions.
> I've added linux-mm@ to CC.

OK, got it.

> VM_FAULT_FALLBACK is
> fallback required.
> -------------------------------------------------------------------------=
--------------------------------------------------
>
> It is a little difficult to reproduce this problem fixed by this patch
> for me. Could you give me some
> hint about how to do this - =E2=80=9Callocate a huge page to replace zero=
 page
> but hit the memcg limit"?
> I used this script:
>
> #!/bin/sh -efu
>
> set -efux
>
> mount -t cgroup none /sys/fs/cgroup
> mkdir /sys/fs/cgroup/test
> echo "10M" > /sys/fs/cgroup/test/memory.limit_in_bytes
> echo "10M" > /sys/fs/cgroup/test/memory.memsw.limit_in_bytes
>
> echo $$ > /sys/fs/cgroup/test/tasks
> /host/home/kas/var/mmaptest_zero
> echo ok
>
> Where /host/home/kas/var/mmaptest_zero is:
>
> #include <assert.h>
> #include <fcntl.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <unistd.h>
> #include <sys/types.h>
> #include <sys/mman.h>
>
> #define MB (1024 * 1024)
> #define SIZE (256 * MB)
>
> int main(int argc, char **argv)
> {
> 	int i;
> 	char *p;
>
> 	posix_memalign((void **)&p, 2 * MB, SIZE);
> 	printf("p: %p\n", p);
> 	fork();
> 	for (i =3D 0; i < SIZE; i +=3D 4096)
> 		assert(p[i] =3D=3D 0);
>
> 	for (i =3D 0; i < SIZE; i +=3D 4096)
> 		p[i] =3D 1;
>
> 	pause();
> 	return 0;
> }
>
> Without the patch it hangs, but should trigger OOM.
>

Thank you very much.

Regards,
Xing Gu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

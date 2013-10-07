Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 911CC6B0036
	for <linux-mm@kvack.org>; Mon,  7 Oct 2013 12:22:53 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rp2so7363352pbb.0
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 09:22:53 -0700 (PDT)
Received: by mail-wi0-f179.google.com with SMTP id hm2so5138165wib.12
        for <linux-mm@kvack.org>; Mon, 07 Oct 2013 09:22:48 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 7 Oct 2013 18:22:48 +0200
Message-ID: <CAP145pinoutWaVCAf1xk8X-Bc8Uu=d2DD8k3w_o=V7caNLqNLA@mail.gmail.com>
Subject: Deadlock (un-killable processes) in sys_futex
From: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

After fuzzing the linux kernel (3.12-rc4) I have two processes which
are stuck in an un-killable state. This is not specific to 3.12-rc4,
as I'm able to reproduce it on most modern kernels (e.g. Ubuntu's 3.5)
after a few minutes of fuzzing with a syscall fuzzer.

The debug data can be found here: http://alt.swiecki.net/linux/20327/
- process PIDs: 20327 and 13735

It includes..

ftrace report (probably the most useful):
I'm not expert in this kernel area (futex/mm), but it seems like a
constatnt loop between fault_in_user_writeable() and do_page_fault():
http://alt.swiecki.net/linux/20327/20327.trace.report.txt

/proc/pid/maps, /proc/pid/status:
http://alt.swiecki.net/linux/20327/20327.maps.txt
http://alt.swiecki.net/linux/20327/20327.status.txt

kdb stacktraces showing that both processes (single-threaded) are
stuck in sys_futex:
http://alt.swiecki.net/linux/20327/20327.kdb.txt
http://alt.swiecki.net/linux/20327/13735.kdb.txt

kgdb stacktraces displaying rather corrupted data:
http://alt.swiecki.net/linux/20327/20327.kgdb.txt
http://alt.swiecki.net/linux/20327/13735.kgdb.txt

kernel conf:
http://alt.swiecki.net/linux/20327/config-3.12-rc4.txt

--=20
Robert =C5=9Awi=C4=99cki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

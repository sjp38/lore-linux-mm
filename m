Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C1D2F6B02E9
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 04:36:01 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j128so264744154pfg.4
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 01:36:01 -0800 (PST)
Received: from mail1.bemta12.messagelabs.com (mail1.bemta12.messagelabs.com. [216.82.251.16])
        by mx.google.com with ESMTPS id g34si21499458pld.184.2016.12.20.01.36.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 01:36:00 -0800 (PST)
From: Dashi DS1 Cao <caods1@lenovo.com>
Subject: A small window for a race condition in
 mm/rmap.c:page_lock_anon_vma_read
Date: Tue, 20 Dec 2016 09:32:27 +0000
Message-ID: <23B7B563BA4E9446B962B142C86EF24ADBD62C@CNMAILEX03.lenovo.com>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

I've collected four crash dumps with similar backtrace.=20

PID: 247    TASK: ffff881fcfad8000  CPU: 14  COMMAND: "kswapd1"
 #0 [ffff881fcfad7978] machine_kexec at ffffffff81051e9b
 #1 [ffff881fcfad79d8] crash_kexec at ffffffff810f27e2
 #2 [ffff881fcfad7aa8] oops_end at ffffffff8163f448
 #3 [ffff881fcfad7ad0] die at ffffffff8101859b
 #4 [ffff881fcfad7b00] do_general_protection at ffffffff8163ed3e
 #5 [ffff881fcfad7b30] general_protection at ffffffff8163e5e8
    [exception RIP: down_read_trylock+9]
    RIP: ffffffff810aa9f9  RSP: ffff881fcfad7be0  RFLAGS: 00010286
    RAX: 0000000000000000  RBX: ffff882b47ddadc0  RCX: 0000000000000000
    RDX: 0000000000000000  RSI: 0000000000000000  RDI: 91550b2b32f5a3e8
    RBP: ffff881fcfad7be0   R8: ffffea00ecc28860   R9: ffff883fcffeae28
    R10: ffffffff81a691a0  R11: 0000000000000001  R12: ffff882b47ddadc1
    R13: ffffea00ecc28840  R14: 91550b2b32f5a3e8  R15: ffffea00ecc28840
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0000
 #6 [ffff881fcfad7be8] page_lock_anon_vma_read at ffffffff811a3365
 #7 [ffff881fcfad7c18] page_referenced at ffffffff811a35e7
 #8 [ffff881fcfad7c90] shrink_active_list at ffffffff8117e8cc
 #9 [ffff881fcfad7d48] balance_pgdat at ffffffff81180288
#10 [ffff881fcfad7e20] kswapd at ffffffff81180813
#11 [ffff881fcfad7ec8] kthread at ffffffff810a5b8f
#12 [ffff881fcfad7f50] ret_from_fork at ffffffff81646a98

I suspect my customer hits into a small window of a race condition in mm/rm=
ap.c: page_lock_anon_vma_read.
struct anon_vma *page_lock_anon_vma_read(struct page *page)
{
        struct anon_vma *anon_vma =3D NULL;
        struct anon_vma *root_anon_vma;
        unsigned long anon_mapping;

        rcu_read_lock();
        anon_mapping =3D (unsigned long)READ_ONCE(page->mapping);
        if ((anon_mapping & PAGE_MAPPING_FLAGS) !=3D PAGE_MAPPING_ANON)
                goto out;
        if (!page_mapped(page))
                goto out;

        anon_vma =3D (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON)=
;
        root_anon_vma =3D READ_ONCE(anon_vma->root);
        if (down_read_trylock(&root_anon_vma->rwsem)) {
                /*
                 * If the page is still mapped, then this anon_vma is still
                 * its anon_vma, and holding the mutex ensures that it will
                 * not go away, see anon_vma_free().
                 */
                if (!page_mapped(page)) {
                        up_read(&root_anon_vma->rwsem);
                        anon_vma =3D NULL;
                }
                goto out;
        }
...
}

Between the time the two "page_mapped(page)" are checked, the address (anon=
_mapping - PAGE_MAPPING_ANON) is unmapped! However it seems that anon_vma->=
root could still be read in but the value is wild. So the kernel crashes in=
 down_read_trylock. But it's weird that all the "struct page" has its membe=
r "_mapcount" still with value 0, not -1, in the four crashes.

Thanks,
Dashi Cao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

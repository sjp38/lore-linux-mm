Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 08B346B025E
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 17:48:21 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p64so47586221pfb.0
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 14:48:21 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id e132si2030100pfg.292.2016.07.08.14.48.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 14:48:19 -0700 (PDT)
Received: by mail-pa0-x229.google.com with SMTP id b13so15743722pat.0
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 14:48:19 -0700 (PDT)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 0/2] binfmt_elf: fix calculations for bss padding
Date: Fri,  8 Jul 2016 14:48:12 -0700
Message-Id: <1468014494-25291-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Kees Cook <keescook@chromium.org>, Hector Marco-Gisbert <hecmargi@upv.es>, Ismael Ripoll Ripoll <iripoll@upv.es>, Alexander Viro <viro@zeniv.linux.org.uk>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Michal Hocko <mhocko@suse.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This fixes a double-bug in ELF loading, as noticed by Hector
Marco-Gisbert. To quote his original email:


 The size of the bss section for some interpreters is not correctly
 calculated resulting in unnecessary calls to vm_brk() with enormous size
 values.

 The bug appears when loading some interpreters with a small bss size. Once
 the last loadable segment has been loaded, the bss section is zeroed up to
 the page boundary and the elf_bss variable is updated to this new page
 boundary.  Because of this update (alignment), the last_bss could be less
 than elf_bss and the subtraction "last_bss - elf_bss" value could overflow.
 ...
 [e.g.] The size value requested to the vm_brk() call (last_bss - elf_bss) is
 0xfffffffffffff938 and internally this size is page aligned in the do_brk()
 function resulting in a 0 length request.


This series takes a slightly different approach to fixing it and updates
vm_brk to refuse bad allocation sizes.

-Kees

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

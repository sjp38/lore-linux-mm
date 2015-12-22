Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id E71736B0005
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 00:31:31 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id cy9so29121196pac.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 21:31:31 -0800 (PST)
Received: from mail-pf0-x22d.google.com (mail-pf0-x22d.google.com. [2607:f8b0:400e:c00::22d])
        by mx.google.com with ESMTPS id e21si9221278pfb.51.2015.12.21.21.31.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 21:31:31 -0800 (PST)
Received: by mail-pf0-x22d.google.com with SMTP id u7so53937018pfb.1
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 21:31:31 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3116\))
Subject: Re: [RFC] mm: change find_vma() function
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <20151215115342.GB75130@black.fi.intel.com>
Date: Tue, 22 Dec 2015 13:31:21 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <35FEEB7C-1C74-4BF9-B2F2-EDB48996BD4F@gmail.com>
References: <1450090945-4020-1-git-send-email-yalin.wang2010@gmail.com> <20151214121107.GB4201@node.shutemov.name> <20151214175509.GA25681@redhat.com> <20151214211132.GA7390@node.shutemov.name> <5603C6DF-DDA5-4B57-9608-63335282B966@gmail.com> <20151215115342.GB75130@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Chen Gang <gang.chen.5i5j@gmail.com>, mhocko@suse.com, kwapulinski.piotr@gmail.com, Andrea Arcangeli <aarcange@redhat.com>, dcashman@google.com, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org


> On Dec 15, 2015, at 19:53, Kirill A. Shutemov =
<kirill.shutemov@linux.intel.com> wrote:
>=20
> On Tue, Dec 15, 2015 at 02:41:21PM +0800, yalin wang wrote:
>>> On Dec 15, 2015, at 05:11, Kirill A. Shutemov <kirill@shutemov.name> =
wrote:
>>> Anyway, I don't think it's possible to gain anything measurable from =
this
>>> optimization.
>>>=20
>> the advantage is that if addr don=E2=80=99t belong to any vma, we =
don=E2=80=99t need loop all vma,
>> we can break earlier if we found the most closest vma which =
vma->end_add > addr,
>=20
> Do you have any workload which can demonstrate the advantage?
>=20
> =E2=80=94=20
i add the log in find_vma() to see the call stack ,
it is very efficient in mmap() / munmap / do_execve() / =
get_unmaped_area() /
mem_cgroup_move_task()->walk_page_range()->find_vma() call ,

in most time the loop will break after search about 7 vm,
i don=E2=80=99t consider the cache pollution problem in this patch,
yeah, this patch will check the vm_prev->vm_end for every loop,
but this only happened when tmp->vm_end > addr ,
if you don=E2=80=99t not check this , you will continue to loop to check =
next rb ,
this will also pollute the cache ,

so the question is which one is better ?
i don=E2=80=99t have a better method to test this .
Any good ideas about this ?
how to test it ?

Thanks







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

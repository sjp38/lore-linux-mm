Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 83B6F6B0007
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 08:52:16 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id u65so4051565wrc.8
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 05:52:16 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n26sor1015917lja.53.2018.03.01.05.52.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Mar 2018 05:52:15 -0800 (PST)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: [RFC PATCH] Randomization of address chosen by mmap.
From: Ilya Smith <blackzert@gmail.com>
In-Reply-To: <CAGXu5jLY4eX5BMU8-2HFr2myjSL717KE-m_SAQp1yeu=cg+w7g@mail.gmail.com>
Date: Thu, 1 Mar 2018 16:52:12 +0300
Content-Transfer-Encoding: quoted-printable
Message-Id: <5E526DB1-08ED-4BD9-AD33-A2EBCC95091E@gmail.com>
References: <20180227131338.3699-1-blackzert@gmail.com>
 <CAGXu5jKF7ysJqj57ZktrcVL4G2NWOFHCud8dtXFHLs=tvVLXnQ@mail.gmail.com>
 <55C92196-5398-4C19-B7A7-6C122CD78F32@gmail.com>
 <CAGXu5jLY4eX5BMU8-2HFr2myjSL717KE-m_SAQp1yeu=cg+w7g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Jerome Glisse <jglisse@redhat.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, Helge Deller <deller@gmx.de>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>


> On 28 Feb 2018, at 22:54, Kees Cook <keescook@chromium.org> wrote:
>=20
> I was trying to understand the target entropy level, and I'm worried
> it's a bit biased. For example, if the first allocation lands at 1/4th
> of the memory space, the next allocation (IIUC) has a 50% chance of
> falling on either side of it. If it goes on the small side, it then
> has much less entropy than if it had gone on the other side. I think
> this may be less entropy than choosing a random address and just
> seeing if it fits or not. Dealing with collisions could be done either
> by pushing the address until it doesn't collide or picking another
> random address, etc. This is probably more expensive, though, since it
> would need to walk the vma tree repeatedly. Anyway, I was ultimately
> curious about your measured entropy and what alternatives you
> considered.

Let me please start with the options we have here.=20
Let's pretend we need to choose random address from free memory pool. =
Let=E2=80=99s=20
pretend we have an array of gaps sorted by size of gap descending. First =
we=20
find the highest index satisfies requested length. For each suitable gap =
(with=20
less index) we count how many pages in this gap satisfies request. And =
compute=20
total count of pages satisfies request. Now we get random by module of =
total=20
number. Subtracting from this value count of suitable gap pages for gaps =
until=20
this value greater we will find needed gap and offset inside it. Add gap =
start=20
to offset we will randomly choose suitable address.
In this scheme we have to keep array of gaps. Each time address space is=20=

changed we have to keep the gaps array consistent and apply this =
changes. It is=20
a very big overhead on any change.

Pure random looks really expensive. Lets try to improve something.

We can=E2=80=99t just choose random address and try do it again and =
again until we find=20
something - this approach has non-deterministic behaviour. Nobody knows =
when it=20
stops. Same if we try to walk tree in random direction.

We can walk tree and try to build array of suitable gaps and choose =
something=20
from there. In my current approach (proof of concept) length of array is =
1 and=20
thats why last gaps would be chosen with more probability. I=E2=80=99m =
agree. It is=20
possible to increase array spending some memory. For example struct mm =
may have=20
to array of 1024 gaps. We do the same, walk tree and randomly fill this =
array (=20
everything locked under write_mem semaphore). When we filled it or =
walked whole=20
tree - choose gap randomly. What do you think about it?

Thanks,
Ilya



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 54FDA6B0092
	for <linux-mm@kvack.org>; Sun, 23 Nov 2014 22:00:18 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id rd3so8629318pab.35
        for <linux-mm@kvack.org>; Sun, 23 Nov 2014 19:00:18 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id xo9si19099525pbc.210.2014.11.23.19.00.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 23 Nov 2014 19:00:16 -0800 (PST)
From: Jijiagang <jijiagang@hisilicon.com>
Subject: RE: UBIFS assert failed in ubifs_set_page_dirty at 1421
Date: Mon, 24 Nov 2014 02:59:51 +0000
Message-ID: <BE257DAADD2C0D439647A27133296657394A65A4@SZXEMA511-MBS.china.huawei.com>
References: <BE257DAADD2C0D439647A271332966573949EFEC@SZXEMA511-MBS.china.huawei.com>
 <1413805935.7906.225.camel@sauron.fi.intel.com>
 <C3050A4DBA34F345975765E43127F10F62CC5D9B@SZXEMA512-MBX.china.huawei.com>
 <1413810719.7906.268.camel@sauron.fi.intel.com>
 <545C2CEE.5020905@huawei.com> <20141120123011.GA9716@node.dhcp.inet.fi>
In-Reply-To: <20141120123011.GA9716@node.dhcp.inet.fi>
Content-Language: zh-CN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Hujianyang <hujianyang@huawei.com>
Cc: "dedekind1@gmail.com" <dedekind1@gmail.com>, Caizhiyong <caizhiyong@hisilicon.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Wanli (welly)" <welly.wan@hisilicon.com>, "linux-mtd@lists.infradead.org" <linux-mtd@lists.infradead.org>, "adrian.hunter@intel.com" <adrian.hunter@intel.com>

Hi Kirill,

I add dump_page(page) in function ubifs_set_page_dirty.
And get this log when ubifs assert fail. Is it helpful for this problem?

page:81411740 count:3 mapcount:1 mapping:a33db634 index:0x0
page flags: 0x219(locked|uptodate|dirty|arch_1)

UBIFS assert failed in ubifs_set_page_dirty at 1424 (pid 545)
CPU: 1 PID: 545 Comm: kswapd0 Tainted: P           O 3.10.0_s40 #18
[<8001d8a0>] (unwind_backtrace+0x0/0x108) from [<80019f44>] (show_stack+0x2=
0/0x24)
[<80019f44>] (show_stack+0x20/0x24) from [<80acf9f8>] (dump_stack+0x24/0x2c=
)
[<80acf9f8>] (dump_stack+0x24/0x2c) from [<80298870>] (ubifs_set_page_dirty=
+0x60/0x6c)
[<80298870>] (ubifs_set_page_dirty+0x60/0x6c) from [<800cea60>] (set_page_d=
irty+0x50/0x78)
[<800cea60>] (set_page_dirty+0x50/0x78) from [<800f4be4>] (try_to_unmap_one=
+0x1f8/0x3d0)
[<800f4be4>] (try_to_unmap_one+0x1f8/0x3d0) from [<800f4f44>] (try_to_unmap=
_file+0x9c/0x740)
[<800f4f44>] (try_to_unmap_file+0x9c/0x740) from [<800f5678>] (try_to_unmap=
+0x40/0x78)
[<800f5678>] (try_to_unmap+0x40/0x78) from [<800d6a04>] (shrink_page_list+0=
x23c/0x884)
[<800d6a04>] (shrink_page_list+0x23c/0x884) from [<800d76c8>] (shrink_inact=
ive_list+0x21c/0x3c8)
[<800d76c8>] (shrink_inactive_list+0x21c/0x3c8) from [<800d7c20>] (shrink_l=
ruvec+0x3ac/0x524)
[<800d7c20>] (shrink_lruvec+0x3ac/0x524) from [<800d8970>] (kswapd+0x854/0x=
dc0)
[<800d8970>] (kswapd+0x854/0xdc0) from [<80051e28>] (kthread+0xc8/0xcc)
[<80051e28>] (kthread+0xc8/0xcc) from [<80015198>] (ret_from_fork+0x14/0x20=
)

> -----Original Message-----
> From: Kirill A. Shutemov [mailto:kirill@shutemov.name]
> Sent: Thursday, November 20, 2014 8:30 PM
> To: Hujianyang
> Cc: dedekind1@gmail.com; Caizhiyong; linux-fsdevel@vger.kernel.org;
> linux-mm@kvack.org; Wanli (welly); linux-mtd@lists.infradead.org;
> adrian.hunter@intel.com; Jijiagang
> Subject: Re: UBIFS assert failed in ubifs_set_page_dirty at 1421
>=20
> On Fri, Nov 07, 2014 at 10:22:38AM +0800, hujianyang wrote:
> > Hi,
> >
> > I think we found the cause of this problem. We enable CONFIG_CMA in
> > our config file. This feature seems to allocate a contiguous memory for=
 caller.
> > If some pages in this contiguous area are used by other modules, like
> > UBIFS, CMA will migrate these pages to other place. This operation
> > should be transparent to the user of old pages. But it is *not true* fo=
r UBIFS.
> >
> > >
> > > 1. UBIFS wants to make sure that no one marks UBIFS-backed pages
> > > (and actually inodes too) as dirty directly. UBIFS wants everyone to
> > > ask UBIFS to mark a page as dirty.
> > >
> > > 2. This is because for every dirty page, UBIFS needs to reserve
> > > certain amount of space on the flash media, because all writes are
> > > out-of-place, even when you are changing an existing file.
> > >
> > > 3. There are exactly 2 places where UBIFS-backed pages may be marked
> > > as
> > > dirty:
> > >
> > >   a) ubifs_write_end() [->wirte_end] - the file write path
> > >   b) ubifs_page_mkwrite() [->page_mkwirte] - the file mmap() path
> >
> > line 1160, func try_to_unmap_one() in mm/rmap.c
> >
> > ""
> >         /* Move the dirty bit to the physical page now the pte is gone.=
 */
> >         if (pte_dirty(pteval))
> >                 set_page_dirty(page);
> > ""
> >
> > Here, If the pte of a page is dirty, a directly set_page_dirty() is
> > performed and hurt the internal logic of UBIFS.
>=20
> If the pte is dirty it must be writable too. And to make pte writable
> ->page_mkwrite() must be called. So it should work fine..
>=20
> Could you check if the pteval is pte_write() by the time?
> And could you provide what says dump_page(page) and dump_vma(vma) while
> you are there?
>=20
> --
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

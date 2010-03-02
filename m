Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0EB0B6B0078
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 08:56:45 -0500 (EST)
Received: by wwb22 with SMTP id 22so136290wwb.14
        for <linux-mm@kvack.org>; Tue, 02 Mar 2010 05:56:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100302134736.GG3212@balbir.in.ibm.com>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	 <1267478620-5276-4-git-send-email-arighi@develer.com>
	 <20100302134736.GG3212@balbir.in.ibm.com>
Date: Tue, 2 Mar 2010 15:56:44 +0200
Message-ID: <cc557aab1003020556kcb3f790yba5bceaeb75c5a4c@mail.gmail.com>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 2, 2010 at 3:47 PM, Balbir Singh <balbir@linux.vnet.ibm.com> wr=
ote:
> * Andrea Righi <arighi@develer.com> [2010-03-01 22:23:40]:
>
>> Apply the cgroup dirty pages accounting and limiting infrastructure to
>> the opportune kernel functions.
>>
>> Signed-off-by: Andrea Righi <arighi@develer.com>
>> ---
>> =C2=A0fs/fuse/file.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A05 +++
>> =C2=A0fs/nfs/write.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A04 ++
>> =C2=A0fs/nilfs2/segment.c | =C2=A0 10 +++++-
>> =C2=A0mm/filemap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A01 +
>> =C2=A0mm/page-writeback.c | =C2=A0 84 ++++++++++++++++++++++++++++++++--=
----------------
>> =C2=A0mm/rmap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A04 +-
>> =C2=A0mm/truncate.c =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A02 +
>> =C2=A07 files changed, 76 insertions(+), 34 deletions(-)
>>
>> diff --git a/fs/fuse/file.c b/fs/fuse/file.c
>> index a9f5e13..dbbdd53 100644
>> --- a/fs/fuse/file.c
>> +++ b/fs/fuse/file.c
>> @@ -11,6 +11,7 @@
>> =C2=A0#include <linux/pagemap.h>
>> =C2=A0#include <linux/slab.h>
>> =C2=A0#include <linux/kernel.h>
>> +#include <linux/memcontrol.h>
>> =C2=A0#include <linux/sched.h>
>> =C2=A0#include <linux/module.h>
>>
>> @@ -1129,6 +1130,8 @@ static void fuse_writepage_finish(struct fuse_conn=
 *fc, struct fuse_req *req)
>>
>> =C2=A0 =C2=A0 =C2=A0 list_del(&req->writepages_entry);
>> =C2=A0 =C2=A0 =C2=A0 dec_bdi_stat(bdi, BDI_WRITEBACK);
>> + =C2=A0 =C2=A0 mem_cgroup_update_stat(req->pages[0],
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
MEM_CGROUP_STAT_WRITEBACK_TEMP, -1);
>> =C2=A0 =C2=A0 =C2=A0 dec_zone_page_state(req->pages[0], NR_WRITEBACK_TEM=
P);
>> =C2=A0 =C2=A0 =C2=A0 bdi_writeout_inc(bdi);
>> =C2=A0 =C2=A0 =C2=A0 wake_up(&fi->page_waitq);
>> @@ -1240,6 +1243,8 @@ static int fuse_writepage_locked(struct page *page=
)
>> =C2=A0 =C2=A0 =C2=A0 req->inode =3D inode;
>>
>> =C2=A0 =C2=A0 =C2=A0 inc_bdi_stat(mapping->backing_dev_info, BDI_WRITEBA=
CK);
>> + =C2=A0 =C2=A0 mem_cgroup_update_stat(tmp_page,
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
MEM_CGROUP_STAT_WRITEBACK_TEMP, 1);
>> =C2=A0 =C2=A0 =C2=A0 inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
>> =C2=A0 =C2=A0 =C2=A0 end_page_writeback(page);
>>
>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>> index b753242..7316f7a 100644
>> --- a/fs/nfs/write.c
>> +++ b/fs/nfs/write.c
>
> Don't need memcontrol.h to be included here?

It's included in <linux/swap.h>

> Looks OK to me overall, but there might be objection using the
> mem_cgroup_* naming convention, but I don't mind it very much :)
>
> --
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Three Cheers,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0Balbir
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =C2=A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

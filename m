Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 34DC68D0039
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 11:18:58 -0500 (EST)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id p2AGIt11011810
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 08:18:55 -0800
Received: from qwb8 (qwb8.prod.google.com [10.241.193.72])
	by kpbe14.cbf.corp.google.com with ESMTP id p2AGHt1S031952
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 08:18:53 -0800
Received: by qwb8 with SMTP id 8so1277804qwb.10
        for <linux-mm@kvack.org>; Thu, 10 Mar 2011 08:18:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110228114018.390ce291.kamezawa.hiroyu@jp.fujitsu.com>
References: <1298669760-26344-1-git-send-email-gthelen@google.com>
 <1298669760-26344-7-git-send-email-gthelen@google.com> <20110227170143.GE3226@barrios-desktop>
 <20110228114018.390ce291.kamezawa.hiroyu@jp.fujitsu.com>
From: Greg Thelen <gthelen@google.com>
Date: Thu, 10 Mar 2011 08:18:33 -0800
Message-ID: <AANLkTimuHeGMY0ELXgsn+BmAibvV34x3RvphF+3SODqw@mail.gmail.com>
Subject: Re: [PATCH v5 6/9] memcg: add kernel calls for memcg dirty page stats
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Chad Talbott <ctalbott@google.com>, Justin TerAvest <teravest@google.com>, Vivek Goyal <vgoyal@redhat.com>

On Sun, Feb 27, 2011 at 6:40 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 28 Feb 2011 02:01:43 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Fri, Feb 25, 2011 at 01:35:57PM -0800, Greg Thelen wrote:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0spin_unlock_irqrestore(&mapping->tree_lock=
, flags);
>> > =A0 =A0 } else {
>> > @@ -1365,6 +1368,7 @@ int test_set_page_writeback(struct page *page)
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 PAGECACHE_TAG_WRITEBACK);
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (bdi_cap_account_writeback(=
bdi))
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __inc_bdi_stat=
(bdi, BDI_WRITEBACK);
>> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_inc_page_stat(page, M=
EMCG_NR_FILE_WRITEBACK);
>>
>> Question:
>> Why should we care of BDI_CAP_NO_WRITEBACK?
>>
> Hmm, should we do ..
> =3D=3D
> =A0 =A0 =A0 =A0if (!ret) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0account_page_writeback(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_inc_page_stat(page, MEMCG_NR_FIL=
E_WRITEBACL);
> =A0 =A0 =A0 =A0}
> =3D=3D

Yes, I agree with Minchan that this is an issue.  I think Kame's fix
is good.  I will apply Kame's fix to test_set_page_writeback().  I
also found that test_clear_page_writeback() has the same issue and it
will also be fixed.  I will be posting v6 shortly (hopefully today)
with these fixes.

> Thanks,
> -Kame
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

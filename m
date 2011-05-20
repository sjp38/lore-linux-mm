Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 254326B0012
	for <linux-mm@kvack.org>; Thu, 19 May 2011 23:38:28 -0400 (EDT)
Received: by pzk4 with SMTP id 4so1957951pzk.14
        for <linux-mm@kvack.org>; Thu, 19 May 2011 20:38:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DD5DC06.6010204@jp.fujitsu.com>
References: <BANLkTikhj1C7+HXP_4T-VnJzPefU2d7b3A@mail.gmail.com>
 <20110512054631.GI6008@one.firstfloor.org> <BANLkTi=fk3DUT9cYd2gAzC98c69F6HXX7g@mail.gmail.com>
 <BANLkTikofp5rHRdW5dXfqJXb8VCAqPQ_7A@mail.gmail.com> <20110514165346.GV6008@one.firstfloor.org>
 <BANLkTik6SS9NH7XVSRBoCR16_5veY0MKBw@mail.gmail.com> <20110514174333.GW6008@one.firstfloor.org>
 <BANLkTinst+Ryox9VZ-s7gdXKa574XXqt5w@mail.gmail.com> <20110515152747.GA25905@localhost>
 <BANLkTim-AnEeL=z1sYm=iN7sMnG0+m0SHw@mail.gmail.com> <20110517060001.GC24069@localhost>
 <BANLkTi=TOm3aLQCD6j=4va6B+Jn2nSfwAg@mail.gmail.com> <BANLkTi=9W6-JXi94rZfTtTpAt3VUiY5fNw@mail.gmail.com>
 <BANLkTikHMUru=w4zzRmosrg2bDbsFWrkTQ@mail.gmail.com> <BANLkTima0hPrPwe_x06afAh+zTi-bOcRMg@mail.gmail.com>
 <BANLkTi=NTLn4Lx7EkybuA8-diTVOvMDxBw@mail.gmail.com> <BANLkTinEDXHuRUYpYN0d95+fz4+F7ccL4w@mail.gmail.com>
 <4DD5DC06.6010204@jp.fujitsu.com>
From: Andrew Lutomirski <luto@mit.edu>
Date: Thu, 19 May 2011 23:38:06 -0400
Message-ID: <BANLkTik=7C5qFZTsPQG4JYY-MEWDTHdc6A@mail.gmail.com>
Subject: Re: Kernel falls apart under light memory pressure (i.e. linking vmlinux)
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: minchan.kim@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, fengguang.wu@intel.com, andi@firstfloor.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hannes@cmpxchg.org, riel@redhat.com

On Thu, May 19, 2011 at 11:12 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> Right after that happened, I hit ctrl-c to kill test_mempressure.sh.
>> The system was OK until I typed sync, and then everything hung.
>>
>> I'm really confused. =A0shrink_inactive_list in
>> RECLAIM_MODE_LUMPYRECLAIM will call one of the isolate_pages functions
>> with ISOLATE_BOTH. =A0The resulting list goes into shrink_page_list,
>> which does VM_BUG_ON(PageActive(page)).
>>
>> How is that supposed to work?
>
> Usually clear_active_flags() clear PG_active before calling
> shrink_page_list().
>
> shrink_inactive_list()
> =A0 =A0isolate_pages_global()
> =A0 =A0update_isolated_counts()
> =A0 =A0 =A0 =A0clear_active_flags()
> =A0 =A0shrink_page_list()
>
>

That makes sense.  And I have CONFIG_COMPACTION=3Dy, so the lumpy mode
doesn't get set anyway.

But the pages I'm seeing have flags=3D100000000008005D.  If I'm reading
it right, that means locked,referenced,uptodate,dirty,active.  How
does a page like that end up in shrink_page_list?  I don't see how a
page that's !PageLRU can get marked Active.  Nonetheless, I'm hitting
that VM_BUG_ON.

Is there a race somewhere?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

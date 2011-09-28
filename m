Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0AC6F9000BD
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 19:48:53 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p8SNmkwe020304
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 16:48:46 -0700
Received: from qyk33 (qyk33.prod.google.com [10.241.83.161])
	by hpaq5.eem.corp.google.com with ESMTP id p8SNfTLC005455
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 28 Sep 2011 16:48:45 -0700
Received: by qyk33 with SMTP id 33so156691qyk.17
        for <linux-mm@kvack.org>; Wed, 28 Sep 2011 16:48:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110928155302.ca394980.kamezawa.hiroyu@jp.fujitsu.com>
References: <1317170947-17074-1-git-send-email-walken@google.com>
	<1317170947-17074-3-git-send-email-walken@google.com>
	<20110928155302.ca394980.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 28 Sep 2011 16:48:44 -0700
Message-ID: <CANN689G_ZT+M4XU+R-d+imDghO4DnvYsS3+=2G2B_5ioh=U7=w@mail.gmail.com>
Subject: Re: [PATCH 2/9] kstaled: documentation and config option.
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Balbir Singh <bsingharora@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Michael Wolf <mjwolf@us.ibm.com>

On Tue, Sep 27, 2011 at 11:53 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 27 Sep 2011 17:49:00 -0700
> Michel Lespinasse <walken@google.com> wrote:
>> +* idle_2_clean, idle_2_dirty_file, idle_2_dirty_swap: same definitions =
as
>> + =A0above, but for pages that have been untouched for at least two scan=
 cycles.
>> +* these fields repeat up to idle_240_clean, idle_240_dirty_file and
>> + =A0idle_240_dirty_swap, allowing one to observe idle pages over a vari=
ety
>> + =A0of idle interval lengths. Note that the accounting is cumulative:
>> + =A0pages counted as idle for a given interval length are also counted
>> + =A0as idle for smaller interval lengths.
>
> I'm sorry if you've answered already.
>
> Why 240 ? and above means we have idle_xxx_clean/dirty/ xxx is 'seq 2 240=
' ?
> Isn't it messy ? Anyway, idle_1_clean etc should be provided.

We don't have all values - we export values for 1, 2, 5, 15, 30, 60,
120 and 240 idle scan intervals.
In our production setup, the scan interval is set at 120 seconds.
The exported histogram values are chosen so that each is approximately
double as the previous, and they align with human units i.e. 30 scan
intervals =3D=3D 1 hour.
We use one byte per page to track the number of idle cycles, which is
why we don't export anything over 255 scan intervals

> Hmm, I don't like the idea very much...
>
> IIUC, there is no kernel interface which shows histgram rather than load_=
avg[].
> Is there any other interface and what histgram is provided ?
> And why histgram by kernel is required ?

I don't think exporting per-page statistics is very useful given that
userspace doesn't have a way to select individual pages to reclaim
(and if it did, we would have to expose LRU lists to userspace for it
to make good choices, and I don't think we want to go there). So, we
want to expose summary statistics instead. Histograms are a good way
to do that.

I don't think averages would work well for this application - the
distribution of idle page ages varies a lot between applications and
can't be assumed to be even close to a gaussian.

> BTW, can't this information be exported by /proc/<pid>/smaps or somewhere=
 ?
> I guess per-proc will be wanted finally.

The problem with per-proc is that it only works for things that are
mapped in at the time you look at the report. It does not take into
consideration ephemeral mappings (i.e. if there is this thing you run
every 5 minutes and it needs 1G of memory) or files you access with
read() instead of mmap().

> Hm, do you use params other than idle_clean for your scheduling ?

The management software currently looks at only one bin of the
histogram - for each job, we can configure which bin it will look at.
Humans look at the complete picture when looking into performance
issues, and we're always thinking about teaching the management
software to do that as well :)

--=20
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

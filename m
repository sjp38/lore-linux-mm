Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 546666B0089
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 21:30:52 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9D1UnuH028293
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 13 Oct 2009 10:30:50 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A48F345DE53
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 10:30:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 791FA45DE4F
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 10:30:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D29BE08002
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 10:30:49 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 07E3F1DB8037
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 10:30:49 +0900 (JST)
Date: Tue, 13 Oct 2009 10:28:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/2] memcg: improving scalability by reducing lock
 contention at charge/uncharge
Message-Id: <20091013102827.c0280e37.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <604427e00910121818w71dd4b7dl8781d7f5bc4f7dd9@mail.gmail.com>
References: <20091002135531.3b5abf5c.kamezawa.hiroyu@jp.fujitsu.com>
	<604427e00910091737s52e11ce9p256c95d533dc2837@mail.gmail.com>
	<f82dee90d0ab51d5bd33a6c01a9feb17.squirrel@webmail-b.css.fujitsu.com>
	<604427e00910111134o6f22f0ddg2b87124dd334ec02@mail.gmail.com>
	<20091013092920.7d509ffa.kamezawa.hiroyu@jp.fujitsu.com>
	<604427e00910121818w71dd4b7dl8781d7f5bc4f7dd9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 12 Oct 2009 18:18:44 -0700
Ying Han <yinghan@google.com> wrote:

> Ok. After I am running the task in the child cgroup, I do see performance
> improvement on the page-faults .

Thank you. 
Hmm...I wonder what makes cache-miss dramatically larger.
4 process on 4 cpus ? (my script was for 8cpus.)

-Kame

> [Before]
>  Performance counter stats for './runpause.sh 10' (5 runs):
> 
>   226190.612998  task-clock-msecs         #      3.766 CPUs    ( +-   0.192%
> )
>            4454  context-switches         #      0.000 M/sec   ( +-  14.029%
> )
>              38  CPU-migrations           #      0.000 M/sec   ( +-  15.385%
> )
>        21445296  page-faults              #      0.095 M/sec   ( +-   1.686%
> )
>    498345012124  cycles                   #   2203.208 M/sec   ( +-   0.023%
> )
>    255638483632  instructions             #      0.513 IPC     ( +-   0.196%
> )
>     92240143452  cache-references         #    407.798 M/sec   ( +-   0.673%
> )
>       175412792  cache-misses             #      0.776 M/sec   ( +-   2.188%
> )
> 
>    60.068670564  seconds time elapsed   ( +-   0.014% )
> 
> [After]
>  Performance counter stats for './runpause.sh 10' (5 runs):
> 
>   214409.926571  task-clock-msecs         #      3.570 CPUs    ( +-   0.317%
> )
>            3097  context-switches         #      0.000 M/sec   ( +-  25.726%
> )
>              14  CPU-migrations           #      0.000 M/sec   ( +-  20.000%
> )
>        33977467  page-faults              #      0.158 M/sec   ( +-   4.884%
> )
>    472369769787  cycles                   #   2203.115 M/sec   ( +-   0.024%
> )
>    275624185415  instructions             #      0.583 IPC     ( +-   0.271%
> )
>     98359325470  cache-references         #    458.744 M/sec   ( +-   0.281%
> )
>       941121561  cache-misses             #      4.389 M/sec   ( +-   4.969%
> )
> 
>    60.052748032  seconds time elapsed   ( +-   0.013% )
> 
> --Ying
> 
> 
> On Mon, Oct 12, 2009 at 5:29 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Sun, 11 Oct 2009 11:34:39 -0700
> > Ying Han <yinghan@google.com> wrote:
> >
> > > 2009/10/10 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > > > This patch series is only for "child" cgroup. Sorry, I had to write it
> > > > clearer. No effects to root.
> > > >
> > >
> > > Ok, Thanks for making it clearer. :) So Do you mind post the cgroup+memcg
> > > configuration
> > > while you are running on your host?
> > >
> >
> > #mount -t cgroup /dev/null /cgroups -omemory
> > #mkdir /cgroups/A
> > #echo $$ > /cgroups/A
> >
> > and run test.
> >
> > Thanks,
> > -Kame
> >
> >
> >
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id B2C0A6B005D
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 23:05:47 -0500 (EST)
Date: Thu, 10 Jan 2013 04:05:46 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH v2] fadvise: perform WILLNEED readahead asynchronously
Message-ID: <20130110040546.GA23797@dcvr.yhbt.net>
References: <20121225022251.GA25992@dcvr.yhbt.net>
 <1357386394.9001.0.camel@kernel.cn.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1357386394.9001.0.camel@kernel.cn.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Dave Chinner <david@fromorbit.com>, Zheng Liu <gnehzuil.liu@gmail.com>

Simon Jeons <simon.jeons@gmail.com> wrote:
> On Tue, 2012-12-25 at 02:22 +0000, Eric Wong wrote:
> 
> Please add changelog.

Changes since v1:

* separate unbound workqueue for high-priority tasks

* account for inflight readahead to avoid denial-of-service

* limit concurrency for non-high-priority tasks (1 per CPU, same as aio)

* take IO priority of requesting process into account when in workqueue.

* process queued readahead in 2M chunks to help ensure fairness between
  multiple requests with few CPUs/workqueues.  Idle tasks get smaller
  256K chunks.

* stops readahead for idle tasks on read congestion

Will try to benchmark with Postgres when I get the chance.

Any other (Free Software) applications that might benefit from
lower FADV_WILLNEED latency?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

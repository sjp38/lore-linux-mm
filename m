Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 41C316B0032
	for <linux-mm@kvack.org>; Sat, 10 Jan 2015 11:05:20 -0500 (EST)
Received: by mail-qc0-f171.google.com with SMTP id r5so13252590qcx.2
        for <linux-mm@kvack.org>; Sat, 10 Jan 2015 08:05:20 -0800 (PST)
Received: from mail-qg0-x22a.google.com (mail-qg0-x22a.google.com. [2607:f8b0:400d:c04::22a])
        by mx.google.com with ESMTPS id h10si16433083qcm.42.2015.01.10.08.05.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 10 Jan 2015 08:05:19 -0800 (PST)
Received: by mail-qg0-f42.google.com with SMTP id q108so12891017qgd.1
        for <linux-mm@kvack.org>; Sat, 10 Jan 2015 08:05:18 -0800 (PST)
Date: Sat, 10 Jan 2015 11:05:15 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET RFC block/for-next] writeback: cgroup writeback support
Message-ID: <20150110160515.GB25319@htj.dyndns.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
 <20150106214426.GA24106@htj.dyndns.org>
 <20150107234532.GD25000@dastard>
 <20150109212336.GB2785@htj.dyndns.org>
 <20150110003819.GP31508@dastard>
 <20150110155653.GA25319@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150110155653.GA25319@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: axboe@kernel.dk, linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com

On Sat, Jan 10, 2015 at 10:56:53AM -0500, Tejun Heo wrote:
...
> backpressure propagation.  If you start mixing pages from different
> cgroups in a single bio, the only options for handling it from the
> lower layer is either splitting it into two separate requests and
> finish the bio only on completion of both or choosing one victim
> cgroup, essentially arbitrarily, both of which can lead to gross
> priority inversion in many circumstances.

Another aspect to consider here is that cfq-iosched doesn't even issue
IOs from different cgroups at the same time.  It schedules time slices
for different cgroups and at any given time only issues a stream of
IOs from a single cgroup.  This is mainly because it's impossible to
determine how much time the target device to process a specific IO
request, especially when it's a write.  The only way we can
approxmiate the cost with an acceptable level of accuracy is bunching
multiple IOs up and then measure the time to finish them in groups so
that the the deviations can be spread across multiple requests.  This
means that we can't issue IOs belonging to different cgroups at the
same time because we can't account for the divisions of cost for the
different cgroups.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

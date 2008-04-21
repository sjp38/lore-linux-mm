Received: by nf-out-0910.google.com with SMTP id h3so1034473nfh.6
        for <linux-mm@kvack.org>; Mon, 21 Apr 2008 13:32:07 -0700 (PDT)
Message-ID: <ab3f9b940804211332i2e75c19co286d7ba1c69ca99b@mail.gmail.com>
Date: Mon, 21 Apr 2008 13:32:06 -0700
From: "Tom May" <tom@tommay.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
In-Reply-To: <20080418170129.A8DF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080417182121.A8CA.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <ab3f9b940804171223m722912bfy291a2c6d9d40b24a@mail.gmail.com>
	 <20080418170129.A8DF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 18, 2008 at 3:07 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:

>  I investigated again and found 2 problem in your test program.
>
>  1. text segment isn't locked.
>
>    if strong memory pressure happned, kernel may drop program text region.
>    then your test program suddenly slow down.
>
>    please use mlockall(MCL_CURRENT) before large buffer allocation.

Using mlock does enable the program to respond faster (and/or the
kernel doesn't have to find memory to fault the page in) and solves
the problem for this simple test program.  I think we're thinking of
the solution in two different ways: you want the program to react more
quickly or be "nicer", and I want the kernel to give notification
early enough to allow time for things that can (and do) happen when
things aren't so nice. I realize that in extreme circumstances oom may
be unavoidable, but a threshold-based notification, in addition to the
current /dev/mem_notify mechanism, would help avoid extreme
circumstances.  I'm going to look into doing this.

>  2. repeat open/close to /proc/meminfo.
>
>    in the fact, open(2) system call use a bit memory.
>    if call open(2) in strong memory pressure, doesn't return until
>    memory freed enough.
>    thus, it cause slow down your program sometimes.

This should be fine; I intentionally do the open/read/write/close
after freeing memory.

>  attached changed test program :)
>  it works well on my test environment.

I made your changes to my program (I'm using clone since I don't have
a pthreads library on my device, and I left PAGESIZE at 4K instead of
64K), and having memory locked does avoid oom in this case, but
unfortunately I don't think it's a general solution that will work
everywhere in my system.  (Although I'm going to try it.)

Thanks,
.tom

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

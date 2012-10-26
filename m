Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id CED0B6B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 02:58:59 -0400 (EDT)
Date: Fri, 26 Oct 2012 14:58:55 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm: readahead: remove redundant ra_pages in file_ra_state
Message-ID: <20121026065855.GA9179@localhost>
References: <CAA9v8mGjdi9Kj7p-yeLJx-nr8C+u4M=QcP5+WcA+5iDs6-thGw@mail.gmail.com>
 <20121024201921.GX4291@dastard>
 <CAA9v8mExDX1TYgCrRfYuh82SnNmNkqC4HjkmczSnz3Ca4zT_qw@mail.gmail.com>
 <20121025015014.GC29378@dastard>
 <CAA9v8mEULAEHn8qSsFokEue3c0hy8pK8bkYB+6xOtz_Tgbp0vw@mail.gmail.com>
 <50889FF1.9030107@gmail.com>
 <20121025025826.GB23462@localhost>
 <20121026002544.GI29378@dastard>
 <20121026012758.GA6282@localhost>
 <5089F5AD.5040708@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5089F5AD.5040708@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ni zhan Chen <nizhan.chen@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, YingHang Zhu <casualfisher@gmail.com>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

>  static void shrink_readahead_size_eio(struct file *filp,
>                                         struct file_ra_state *ra)
>  {
> -       ra->ra_pages /= 4;
> +       spin_lock(&filp->f_lock);
> +       filp->f_mode |= FMODE_RANDOM;
> +       spin_unlock(&filp->f_lock);
> 
> As the example in comment above this function, the read maybe still
> sequential, and it will waste IO bandwith if modify to FMODE_RANDOM
> directly.

Yes immediately disabling readahead may hurt IO performance, the
original '/ 4' may perform better when there are only 1-3 IO errors
encountered.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

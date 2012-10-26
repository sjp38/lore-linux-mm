Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 10CF96B0072
	for <linux-mm@kvack.org>; Fri, 26 Oct 2012 03:09:43 -0400 (EDT)
Date: Fri, 26 Oct 2012 15:09:36 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm: readahead: remove redundant ra_pages in file_ra_state
Message-ID: <20121026070936.GA12282@localhost>
References: <CAA9v8mExDX1TYgCrRfYuh82SnNmNkqC4HjkmczSnz3Ca4zT_qw@mail.gmail.com>
 <20121025015014.GC29378@dastard>
 <CAA9v8mEULAEHn8qSsFokEue3c0hy8pK8bkYB+6xOtz_Tgbp0vw@mail.gmail.com>
 <50889FF1.9030107@gmail.com>
 <20121025025826.GB23462@localhost>
 <20121026002544.GI29378@dastard>
 <20121026012758.GA6282@localhost>
 <5089F5AD.5040708@gmail.com>
 <20121026065855.GA9179@localhost>
 <508A35B0.30106@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <508A35B0.30106@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ni zhan Chen <nizhan.chen@gmail.com>
Cc: Dave Chinner <david@fromorbit.com>, YingHang Zhu <casualfisher@gmail.com>, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Oct 26, 2012 at 03:03:12PM +0800, Ni zhan Chen wrote:
> On 10/26/2012 02:58 PM, Fengguang Wu wrote:
> >>  static void shrink_readahead_size_eio(struct file *filp,
> >>                                         struct file_ra_state *ra)
> >>  {
> >>-       ra->ra_pages /= 4;
> >>+       spin_lock(&filp->f_lock);
> >>+       filp->f_mode |= FMODE_RANDOM;
> >>+       spin_unlock(&filp->f_lock);
> >>
> >>As the example in comment above this function, the read maybe still
> >>sequential, and it will waste IO bandwith if modify to FMODE_RANDOM
> >>directly.
> >Yes immediately disabling readahead may hurt IO performance, the
> >original '/ 4' may perform better when there are only 1-3 IO errors
> >encountered.
> 
> Hi Fengguang,
> 
> Why the number should be 1-3?

The original behavior is '/= 4' on each error.

After 1 errors, readahead size will be shrinked by 1/4
After 2 errors, readahead size will be shrinked by 1/16
After 3 errors, readahead size will be shrinked by 1/64
After 4 errors, readahead size will be effectively 0 (disabled)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 715AC6B01EE
	for <linux-mm@kvack.org>; Fri, 14 May 2010 01:52:42 -0400 (EDT)
Date: Fri, 14 May 2010 13:52:36 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC, 3/7] NUMA hotplug emulator
Message-ID: <20100514055236.GA29036@localhost>
References: <20100513114835.GD2169@shaohui>
 <4BECC418.2080602@linux.intel.com>
 <20100514041136.GA12020@localhost>
 <4BECE052.5020907@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4BECE052.5020907@linux.intel.com>
Sender: owner-linux-mm@kvack.org
To: Haicheng Li <haicheng.li@linux.intel.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>, Greg Kroah-Hartman <gregkh@suse.de>, David Rientjes <rientjes@google.com>, Alex Chiang <achiang@hp.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "ak@linux.intel.co" <ak@linux.intel.co>, "shaohui.zheng@linux.intel.com" <shaohui.zheng@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Fri, May 14, 2010 at 01:32:02PM +0800, Haicheng Li wrote:
> Wu Fengguang wrote:
> >> Pls. replace it with following code:
> >>
> >> +#ifdef CONFIG_NODE_HOTPLUG_EMU
> >> +static ssize_t store_nodes_probe(struct sysdev_class *class,
> >> +                                 struct sysdev_class_attribute *attr,
> >> +                                 const char *buf, size_t count)
> >> +{
> >> +       long nid;
> >> +       int ret;
> >> +
> >> +       ret = strict_strtol(buf, 0, &nid);
> >> +       if (ret == -EINVAL)
> >> +               return ret;
> >> +
> >> +       ret = hotadd_hidden_nodes(nid);
> >> +       if (!ret)
> >> +               return count;
> >> +       else
> >> +               return -EIO;
> >> +}
> >> +#endif
> > 
> > How about this?
> > 
> >        err = strict_strtol(buf, 0, &nid);
> >        if (err < 0)
> >                return err;
> 
> other negative value would be odd here.

Yes, strict_strtoul() will be better.

> >        err = hotadd_hidden_nodes(nid);
> >        if (err < 0)
> >                return err;
> 
> hotadd_hidden_nodes could return -EEXIST, which is also odd here, right?

Why not? write(2) says "Other errors may occur, depending on the
object connected to fd."

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

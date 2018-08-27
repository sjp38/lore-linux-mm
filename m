Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CE6D86B4093
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 08:52:43 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id x20-v6so6540182eda.22
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 05:52:43 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k46-v6si2397045edb.231.2018.08.27.05.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 05:52:42 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w7RCca6v144921
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 08:52:41 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2m4h7th624-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 08:52:40 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 27 Aug 2018 13:52:38 +0100
Date: Mon, 27 Aug 2018 15:52:27 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] clk: pmc-atom: use devm_kstrdup_const()
References: <20180827082101.5036-1-brgl@bgdev.pl>
 <20180827082101.5036-2-brgl@bgdev.pl>
 <20180827103915.GC13848@rapoport-lnx>
 <CAMRc=MeCRw459ppuVK=w53C2eHOVVHPksF_4hx_dY1J-3fgPsQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMRc=MeCRw459ppuVK=w53C2eHOVVHPksF_4hx_dY1J-3fgPsQ@mail.gmail.com>
Message-Id: <20180827125226.GD13848@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartosz Golaszewski <brgl@bgdev.pl>
Cc: Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Kees Cook <keescook@chromium.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, linux-clk <linux-clk@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Aug 27, 2018 at 02:28:45PM +0200, Bartosz Golaszewski wrote:
> 2018-08-27 12:39 GMT+02:00 Mike Rapoport <rppt@linux.vnet.ibm.com>:
> > On Mon, Aug 27, 2018 at 10:21:01AM +0200, Bartosz Golaszewski wrote:
> >> Use devm_kstrdup_const() in the pmc-atom driver. This mostly serves as
> >> an example of how to use this new routine to shrink driver code.
> >>
> >> While we're at it: replace a call to kcalloc() with devm_kcalloc().
> >>
> >> Signed-off-by: Bartosz Golaszewski <brgl@bgdev.pl>
> >> ---
> >>  drivers/clk/x86/clk-pmc-atom.c | 19 ++++---------------
> >>  1 file changed, 4 insertions(+), 15 deletions(-)
> >>
> >> diff --git a/drivers/clk/x86/clk-pmc-atom.c b/drivers/clk/x86/clk-pmc-atom.c
> >> index 08ef69945ffb..daa2192e6568 100644
> >> --- a/drivers/clk/x86/clk-pmc-atom.c
> >> +++ b/drivers/clk/x86/clk-pmc-atom.c
> >> @@ -253,14 +253,6 @@ static void plt_clk_unregister_fixed_rate_loop(struct clk_plt_data *data,
> >>               plt_clk_unregister_fixed_rate(data->parents[i]);
> >>  }
> >>
> >> -static void plt_clk_free_parent_names_loop(const char **parent_names,
> >> -                                        unsigned int i)
> >> -{
> >> -     while (i--)
> >> -             kfree_const(parent_names[i]);
> >> -     kfree(parent_names);
> >> -}
> >> -
> >>  static void plt_clk_unregister_loop(struct clk_plt_data *data,
> >>                                   unsigned int i)
> >>  {
> >> @@ -286,8 +278,8 @@ static const char **plt_clk_register_parents(struct platform_device *pdev,
> >>       if (!data->parents)
> >>               return ERR_PTR(-ENOMEM);
> >>
> >> -     parent_names = kcalloc(nparents, sizeof(*parent_names),
> >> -                            GFP_KERNEL);
> >> +     parent_names = devm_kcalloc(&pdev->dev, nparents,
> >> +                                 sizeof(*parent_names), GFP_KERNEL);
> >>       if (!parent_names)
> >>               return ERR_PTR(-ENOMEM);
> >>
> >> @@ -300,7 +292,8 @@ static const char **plt_clk_register_parents(struct platform_device *pdev,
> >>                       err = PTR_ERR(data->parents[i]);
> >>                       goto err_unreg;
> >>               }
> >> -             parent_names[i] = kstrdup_const(clks[i].name, GFP_KERNEL);
> >> +             parent_names[i] = devm_kstrdup_const(&pdev->dev,
> >> +                                                  clks[i].name, GFP_KERNEL);
> >>       }
> >>
> >>       data->nparents = nparents;
> >> @@ -308,7 +301,6 @@ static const char **plt_clk_register_parents(struct platform_device *pdev,
> >>
> >>  err_unreg:
> >>       plt_clk_unregister_fixed_rate_loop(data, i);
> >> -     plt_clk_free_parent_names_loop(parent_names, i);
> >
> > What happens if clks[i].name is not a part of RO data? The devm_kstrdup_const
> > will allocate memory and nothing will ever free it...
> >
> 
> I'm looking at it and trying to see if I'm missing something, but
> AFAIK the whole concept of devm_* is to leave out the resource
> management part.
> 
> devm_kstrdup_const() will internally call devm_kstrdup() for strings
> that are not in .rodata and once the device is detached, the string
> will be freed (or not if it's in .rodata).

And when it's going to be freed, how the resource management will know
whether it's .rodata or not?
 
> BR
> Bart
> 
> > And, please don't drop kfree(parent_names) here.
> >
> >>       return ERR_PTR(err);
> >>  }
> >>
> >> @@ -351,15 +343,12 @@ static int plt_clk_probe(struct platform_device *pdev)
> >>               goto err_unreg_clk_plt;
> >>       }
> >>
> >> -     plt_clk_free_parent_names_loop(parent_names, data->nparents);
> >> -
> >>       platform_set_drvdata(pdev, data);
> >>       return 0;
> >>
> >>  err_unreg_clk_plt:
> >>       plt_clk_unregister_loop(data, i);
> >>       plt_clk_unregister_parents(data);
> >> -     plt_clk_free_parent_names_loop(parent_names, data->nparents);
> >
> > Ditto.
> >
> >>       return err;
> >>  }
> >>
> >> --
> >> 2.18.0
> >>
> >
> > --
> > Sincerely yours,
> > Mike.
> >
> 

-- 
Sincerely yours,
Mike.

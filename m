Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 94E1B6B4008
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 06:39:32 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id d47-v6so6486561edb.3
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 03:39:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 39-v6si6180761edq.240.2018.08.27.03.39.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 03:39:31 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w7RAXjr3139566
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 06:39:29 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2m4dj9n0tn-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 06:39:29 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 27 Aug 2018 11:39:27 +0100
Date: Mon, 27 Aug 2018 13:39:16 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] clk: pmc-atom: use devm_kstrdup_const()
References: <20180827082101.5036-1-brgl@bgdev.pl>
 <20180827082101.5036-2-brgl@bgdev.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180827082101.5036-2-brgl@bgdev.pl>
Message-Id: <20180827103915.GC13848@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bartosz Golaszewski <brgl@bgdev.pl>
Cc: Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Kees Cook <keescook@chromium.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, linux-clk@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Aug 27, 2018 at 10:21:01AM +0200, Bartosz Golaszewski wrote:
> Use devm_kstrdup_const() in the pmc-atom driver. This mostly serves as
> an example of how to use this new routine to shrink driver code.
> 
> While we're at it: replace a call to kcalloc() with devm_kcalloc().
> 
> Signed-off-by: Bartosz Golaszewski <brgl@bgdev.pl>
> ---
>  drivers/clk/x86/clk-pmc-atom.c | 19 ++++---------------
>  1 file changed, 4 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/clk/x86/clk-pmc-atom.c b/drivers/clk/x86/clk-pmc-atom.c
> index 08ef69945ffb..daa2192e6568 100644
> --- a/drivers/clk/x86/clk-pmc-atom.c
> +++ b/drivers/clk/x86/clk-pmc-atom.c
> @@ -253,14 +253,6 @@ static void plt_clk_unregister_fixed_rate_loop(struct clk_plt_data *data,
>  		plt_clk_unregister_fixed_rate(data->parents[i]);
>  }
> 
> -static void plt_clk_free_parent_names_loop(const char **parent_names,
> -					   unsigned int i)
> -{
> -	while (i--)
> -		kfree_const(parent_names[i]);
> -	kfree(parent_names);
> -}
> -
>  static void plt_clk_unregister_loop(struct clk_plt_data *data,
>  				    unsigned int i)
>  {
> @@ -286,8 +278,8 @@ static const char **plt_clk_register_parents(struct platform_device *pdev,
>  	if (!data->parents)
>  		return ERR_PTR(-ENOMEM);
> 
> -	parent_names = kcalloc(nparents, sizeof(*parent_names),
> -			       GFP_KERNEL);
> +	parent_names = devm_kcalloc(&pdev->dev, nparents,
> +				    sizeof(*parent_names), GFP_KERNEL);
>  	if (!parent_names)
>  		return ERR_PTR(-ENOMEM);
> 
> @@ -300,7 +292,8 @@ static const char **plt_clk_register_parents(struct platform_device *pdev,
>  			err = PTR_ERR(data->parents[i]);
>  			goto err_unreg;
>  		}
> -		parent_names[i] = kstrdup_const(clks[i].name, GFP_KERNEL);
> +		parent_names[i] = devm_kstrdup_const(&pdev->dev,
> +						     clks[i].name, GFP_KERNEL);
>  	}
> 
>  	data->nparents = nparents;
> @@ -308,7 +301,6 @@ static const char **plt_clk_register_parents(struct platform_device *pdev,
> 
>  err_unreg:
>  	plt_clk_unregister_fixed_rate_loop(data, i);
> -	plt_clk_free_parent_names_loop(parent_names, i);

What happens if clks[i].name is not a part of RO data? The devm_kstrdup_const
will allocate memory and nothing will ever free it...

And, please don't drop kfree(parent_names) here.

>  	return ERR_PTR(err);
>  }
> 
> @@ -351,15 +343,12 @@ static int plt_clk_probe(struct platform_device *pdev)
>  		goto err_unreg_clk_plt;
>  	}
> 
> -	plt_clk_free_parent_names_loop(parent_names, data->nparents);
> -
>  	platform_set_drvdata(pdev, data);
>  	return 0;
> 
>  err_unreg_clk_plt:
>  	plt_clk_unregister_loop(data, i);
>  	plt_clk_unregister_parents(data);
> -	plt_clk_free_parent_names_loop(parent_names, data->nparents);

Ditto.

>  	return err;
>  }
> 
> -- 
> 2.18.0
> 

-- 
Sincerely yours,
Mike.

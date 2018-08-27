Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 122AF6B4099
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 08:58:48 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id w196-v6so8458789itb.4
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 05:58:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r6-v6sor5245513ioo.175.2018.08.27.05.58.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Aug 2018 05:58:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180827125226.GD13848@rapoport-lnx>
References: <20180827082101.5036-1-brgl@bgdev.pl> <20180827082101.5036-2-brgl@bgdev.pl>
 <20180827103915.GC13848@rapoport-lnx> <CAMRc=MeCRw459ppuVK=w53C2eHOVVHPksF_4hx_dY1J-3fgPsQ@mail.gmail.com>
 <20180827125226.GD13848@rapoport-lnx>
From: Bartosz Golaszewski <brgl@bgdev.pl>
Date: Mon, 27 Aug 2018 14:58:46 +0200
Message-ID: <CAMRc=MchWQEiH82KYdXvPWzJ6U9YLLJ8425M3Jct1O0EMZpokA@mail.gmail.com>
Subject: Re: [PATCH 2/2] clk: pmc-atom: use devm_kstrdup_const()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Kees Cook <keescook@chromium.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, linux-clk <linux-clk@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

2018-08-27 14:52 GMT+02:00 Mike Rapoport <rppt@linux.vnet.ibm.com>:
> On Mon, Aug 27, 2018 at 02:28:45PM +0200, Bartosz Golaszewski wrote:
>> 2018-08-27 12:39 GMT+02:00 Mike Rapoport <rppt@linux.vnet.ibm.com>:
>> > On Mon, Aug 27, 2018 at 10:21:01AM +0200, Bartosz Golaszewski wrote:
>> >> Use devm_kstrdup_const() in the pmc-atom driver. This mostly serves as
>> >> an example of how to use this new routine to shrink driver code.
>> >>
>> >> While we're at it: replace a call to kcalloc() with devm_kcalloc().
>> >>
>> >> Signed-off-by: Bartosz Golaszewski <brgl@bgdev.pl>
>> >> ---
>> >>  drivers/clk/x86/clk-pmc-atom.c | 19 ++++---------------
>> >>  1 file changed, 4 insertions(+), 15 deletions(-)
>> >>
>> >> diff --git a/drivers/clk/x86/clk-pmc-atom.c b/drivers/clk/x86/clk-pmc-atom.c
>> >> index 08ef69945ffb..daa2192e6568 100644
>> >> --- a/drivers/clk/x86/clk-pmc-atom.c
>> >> +++ b/drivers/clk/x86/clk-pmc-atom.c
>> >> @@ -253,14 +253,6 @@ static void plt_clk_unregister_fixed_rate_loop(struct clk_plt_data *data,
>> >>               plt_clk_unregister_fixed_rate(data->parents[i]);
>> >>  }
>> >>
>> >> -static void plt_clk_free_parent_names_loop(const char **parent_names,
>> >> -                                        unsigned int i)
>> >> -{
>> >> -     while (i--)
>> >> -             kfree_const(parent_names[i]);
>> >> -     kfree(parent_names);
>> >> -}
>> >> -
>> >>  static void plt_clk_unregister_loop(struct clk_plt_data *data,
>> >>                                   unsigned int i)
>> >>  {
>> >> @@ -286,8 +278,8 @@ static const char **plt_clk_register_parents(struct platform_device *pdev,
>> >>       if (!data->parents)
>> >>               return ERR_PTR(-ENOMEM);
>> >>
>> >> -     parent_names = kcalloc(nparents, sizeof(*parent_names),
>> >> -                            GFP_KERNEL);
>> >> +     parent_names = devm_kcalloc(&pdev->dev, nparents,
>> >> +                                 sizeof(*parent_names), GFP_KERNEL);
>> >>       if (!parent_names)
>> >>               return ERR_PTR(-ENOMEM);
>> >>
>> >> @@ -300,7 +292,8 @@ static const char **plt_clk_register_parents(struct platform_device *pdev,
>> >>                       err = PTR_ERR(data->parents[i]);
>> >>                       goto err_unreg;
>> >>               }
>> >> -             parent_names[i] = kstrdup_const(clks[i].name, GFP_KERNEL);
>> >> +             parent_names[i] = devm_kstrdup_const(&pdev->dev,
>> >> +                                                  clks[i].name, GFP_KERNEL);
>> >>       }
>> >>
>> >>       data->nparents = nparents;
>> >> @@ -308,7 +301,6 @@ static const char **plt_clk_register_parents(struct platform_device *pdev,
>> >>
>> >>  err_unreg:
>> >>       plt_clk_unregister_fixed_rate_loop(data, i);
>> >> -     plt_clk_free_parent_names_loop(parent_names, i);
>> >
>> > What happens if clks[i].name is not a part of RO data? The devm_kstrdup_const
>> > will allocate memory and nothing will ever free it...
>> >
>>
>> I'm looking at it and trying to see if I'm missing something, but
>> AFAIK the whole concept of devm_* is to leave out the resource
>> management part.
>>
>> devm_kstrdup_const() will internally call devm_kstrdup() for strings
>> that are not in .rodata and once the device is detached, the string
>> will be freed (or not if it's in .rodata).
>
> And when it's going to be freed, how the resource management will know
> whether it's .rodata or not?
>

If the string to be duplicated is in .rodata, it's returned as is from
devm_kstrdup_const(). Never gets added to the devres list, never get's
freed. When the string to be duplicated is not in .rodata,
devm_kstrdup() is called from devm_kstrdup_const(). Now the string is
in the devres list of this device and it will get freed on driver
detach. I really don't see what else could be a problem here.

BR
Bart

>> BR
>> Bart
>>
>> > And, please don't drop kfree(parent_names) here.
>> >
>> >>       return ERR_PTR(err);
>> >>  }
>> >>
>> >> @@ -351,15 +343,12 @@ static int plt_clk_probe(struct platform_device *pdev)
>> >>               goto err_unreg_clk_plt;
>> >>       }
>> >>
>> >> -     plt_clk_free_parent_names_loop(parent_names, data->nparents);
>> >> -
>> >>       platform_set_drvdata(pdev, data);
>> >>       return 0;
>> >>
>> >>  err_unreg_clk_plt:
>> >>       plt_clk_unregister_loop(data, i);
>> >>       plt_clk_unregister_parents(data);
>> >> -     plt_clk_free_parent_names_loop(parent_names, data->nparents);
>> >
>> > Ditto.
>> >
>> >>       return err;
>> >>  }
>> >>
>> >> --
>> >> 2.18.0
>> >>
>> >
>> > --
>> > Sincerely yours,
>> > Mike.
>> >
>>
>
> --
> Sincerely yours,
> Mike.
>

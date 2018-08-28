Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 018FD6B456F
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 05:34:13 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id w6-v6so831305wrc.22
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 02:34:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x18-v6sor234709wrt.8.2018.08.28.02.34.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Aug 2018 02:34:11 -0700 (PDT)
From: Bartosz Golaszewski <brgl@bgdev.pl>
Subject: [PATCH v2 4/4] clk: pmc-atom: use devm_kstrdup_const()
Date: Tue, 28 Aug 2018 11:33:32 +0200
Message-Id: <20180828093332.20674-5-brgl@bgdev.pl>
In-Reply-To: <20180828093332.20674-1-brgl@bgdev.pl>
References: <20180828093332.20674-1-brgl@bgdev.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Turquette <mturquette@baylibre.com>, Stephen Boyd <sboyd@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Arend van Spriel <aspriel@gmail.com>, Ulf Hansson <ulf.hansson@linaro.org>, Bjorn Helgaas <bhelgaas@google.com>, Vivek Gautam <vivek.gautam@codeaurora.org>, Robin Murphy <robin.murphy@arm.com>, Joe Perches <joe@perches.com>, Heikki Krogerus <heikki.krogerus@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Roman Gushchin <guro@fb.com>, Huang Ying <ying.huang@intel.com>, Kees Cook <keescook@chromium.org>, Bjorn Andersson <bjorn.andersson@linaro.org>, Arnd Bergmann <arnd@arndb.de>
Cc: linux-clk@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Bartosz Golaszewski <brgl@bgdev.pl>

Use devm_kstrdup_const() in the pmc-atom driver. This mostly serves as
an example of how to use this new routine to shrink driver code.

While we're at it: replace a call to kcalloc() with devm_kcalloc().

Signed-off-by: Bartosz Golaszewski <brgl@bgdev.pl>
---
 drivers/clk/x86/clk-pmc-atom.c | 19 ++++---------------
 1 file changed, 4 insertions(+), 15 deletions(-)

diff --git a/drivers/clk/x86/clk-pmc-atom.c b/drivers/clk/x86/clk-pmc-atom.c
index 08ef69945ffb..daa2192e6568 100644
--- a/drivers/clk/x86/clk-pmc-atom.c
+++ b/drivers/clk/x86/clk-pmc-atom.c
@@ -253,14 +253,6 @@ static void plt_clk_unregister_fixed_rate_loop(struct clk_plt_data *data,
 		plt_clk_unregister_fixed_rate(data->parents[i]);
 }
 
-static void plt_clk_free_parent_names_loop(const char **parent_names,
-					   unsigned int i)
-{
-	while (i--)
-		kfree_const(parent_names[i]);
-	kfree(parent_names);
-}
-
 static void plt_clk_unregister_loop(struct clk_plt_data *data,
 				    unsigned int i)
 {
@@ -286,8 +278,8 @@ static const char **plt_clk_register_parents(struct platform_device *pdev,
 	if (!data->parents)
 		return ERR_PTR(-ENOMEM);
 
-	parent_names = kcalloc(nparents, sizeof(*parent_names),
-			       GFP_KERNEL);
+	parent_names = devm_kcalloc(&pdev->dev, nparents,
+				    sizeof(*parent_names), GFP_KERNEL);
 	if (!parent_names)
 		return ERR_PTR(-ENOMEM);
 
@@ -300,7 +292,8 @@ static const char **plt_clk_register_parents(struct platform_device *pdev,
 			err = PTR_ERR(data->parents[i]);
 			goto err_unreg;
 		}
-		parent_names[i] = kstrdup_const(clks[i].name, GFP_KERNEL);
+		parent_names[i] = devm_kstrdup_const(&pdev->dev,
+						     clks[i].name, GFP_KERNEL);
 	}
 
 	data->nparents = nparents;
@@ -308,7 +301,6 @@ static const char **plt_clk_register_parents(struct platform_device *pdev,
 
 err_unreg:
 	plt_clk_unregister_fixed_rate_loop(data, i);
-	plt_clk_free_parent_names_loop(parent_names, i);
 	return ERR_PTR(err);
 }
 
@@ -351,15 +343,12 @@ static int plt_clk_probe(struct platform_device *pdev)
 		goto err_unreg_clk_plt;
 	}
 
-	plt_clk_free_parent_names_loop(parent_names, data->nparents);
-
 	platform_set_drvdata(pdev, data);
 	return 0;
 
 err_unreg_clk_plt:
 	plt_clk_unregister_loop(data, i);
 	plt_clk_unregister_parents(data);
-	plt_clk_free_parent_names_loop(parent_names, data->nparents);
 	return err;
 }
 
-- 
2.18.0
